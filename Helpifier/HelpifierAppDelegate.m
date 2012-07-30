//
//  HelpifierAppDelegate.m
//  Helpifier
//
//  Created by Sean Dougall on 11/18/11.
//  Copyright 2012 Figure 53. All rights reserved.
//

#import "HelpifierAppDelegate.h"
#import "HelpSpotController.h"
#import "RequestCellView.h"
#import "RequestController.h"
#import "PreferencesController.h"
#import "Notifier.h"
#import "FHSModel.h"
#import "FFSSettings.h"

@interface HelpifierAppDelegate ()

- (void)_loadingDidFinish:(NSNotification *)note;
- (void)_requestNotFound:(NSNotification *)note;
- (void)_statusTypesDidUpdate:(NSNotification *)note;
- (void)_authenticationNeeded:(NSNotification *)note;

- (void)_addRowsForNewRequestsInFilter:(FHSFilter *)filter;
- (void)_removeRowsForRequestsInFilter:(FHSFilter *)filter;

- (void)_pushRequest:(FHSRequest *)request;
- (NSRect)_frameForRequestView;
- (void)_finishedPushingRequest;
- (void)_setBadgeLabelWithUnreadCount;

- (void)_showConnectionPreferences;

@property (strong) RequestController *requestController;
@property (strong) RequestController *oldRequestController;
@property (strong) PreferencesController *preferencesController;
@property (strong) Notifier *notifier;
@property (assign) BOOL hasUpdated;
@property (assign) CGFloat sidebarWidthBeforeResizing;

@end

#pragma mark -

@implementation HelpifierAppDelegate

@synthesize window = _window;

@synthesize splitView = _splitView;

- (void)setSplitView:(NSSplitView *)splitView
{
    _splitView = splitView;
    _sidebarWidthBeforeResizing = [[NSUserDefaults standardUserDefaults] floatForKey:@"HelpifierSidebarWidth"];
    if ( _sidebarWidthBeforeResizing == 0.0 )
        _sidebarWidthBeforeResizing = [[[_splitView subviews] objectAtIndex:0] frame].size.width;
    [_splitView setPosition:_sidebarWidthBeforeResizing ofDividerAtIndex:0];
}

@synthesize requestList = _requestList;

@synthesize containerView = _containerView;

@synthesize requestView = _requestView;

@synthesize noRequestView = _noRequestView;

@synthesize requestNotFoundView = _requestNotFoundView;

@synthesize noRequestLabel = _noRequestLabel;

@synthesize requestListFooterView = _requestListFooterView;

@synthesize requestController = _requestController;

@synthesize oldRequestController = _oldRequestController;

@synthesize preferencesController = _preferencesController;

@synthesize notifier = _notifier;

@synthesize hasUpdated = _hasUpdated;

@synthesize sidebarWidthBeforeResizing = _sidebarWidthBeforeResizing;

@synthesize refreshButton = _refreshButton;

@synthesize loadingIndicator = _loadingIndicator;

@synthesize warningImageView = _warningImageView;

@synthesize otherRequestButton = _otherRequestButton;

@synthesize otherRequestPopover = _otherRequestPopover;

- (FHSStatusTypeCollection *)statusTypes
{
    return [_helpSpot statusTypes];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _hasUpdated = NO;
    [_requestList reloadData];  ///< Do this first so INBOX, MY QUEUE, and SUBSCRIPTIONS headings show up in the list while we load.
    
    _helpSpot = [[HelpSpotController alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _loadingDidFinish: ) name:FHSFilterDidFinishLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _loadingDidFinish: ) name:FHSStandaloneRequestDidFinishLoadingNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _requestNotFound: ) name:FHSRequestNotFoundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _statusTypesDidUpdate: ) name:FHSStatusTypeCollectionDidFinishLoadingNotification object:nil];
    [_helpSpot addObserver:self forKeyPath:@"lastError" options:NSKeyValueObservingOptionNew context:nil];
    [_helpSpot start];
    
    if ( [[[FFSSettings sharedSettings] helpSpotPassword] length] == 0 )
        [self showPreferences:self];
    
    _notifier = [[Notifier alloc] init];
}

- (void)awakeFromNib
{
    // This gets called every time a table cell view is dequeued. Yup, it's stupid, but that means we can't do much important stuff here.
    // TODO: Is that fixable by putting the table cell views in a separate xib file? (non-urgent)
}

- (IBAction)showPreferences:(id)sender
{
    if ( _preferencesController == nil )
        _preferencesController = [[PreferencesController alloc] init];
    
    [_preferencesController showPreferences];
}

- (void)_showConnectionPreferences
{
    if ( _preferencesController == nil )
        _preferencesController = [[PreferencesController alloc] init];
    
    [_preferencesController showConnectionPreferences:self];
}

- (IBAction)refreshNow:(id)sender
{
    [_helpSpot refresh];
}

- (IBAction)showHelp:(id)sender
{
    NSArray *responses = [NSArray arrayWithObjects:
                          @"me if you can, I'm feeling down.",
                          @"I need somebody. Not just anybody.",
                          @"me get my feet back on the ground.",
                          nil];
    NSRunAlertPanel( @"Help", [responses objectAtIndex:(random() % responses.count)], @"OK", nil, nil );
}

- (IBAction)selectOtherRequest:(id)sender
{
    if ( _otherRequestPopover.shown )
        [_otherRequestPopover close];
    else
        [_otherRequestPopover showRelativeToRect:_otherRequestButton.bounds ofView:_otherRequestButton preferredEdge:NSMaxYEdge];
}

- (void)goToOtherRequest:(NSInteger)requestNumber
{
    [_otherRequestPopover close];
    if ( requestNumber > 0 )
    {
        FHSRequest *request = [[FHSRequest alloc] initWithRequestID:requestNumber delegate:_helpSpot.inboxFilter];
        [self _pushRequest:request];
        [_requestList selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    }
}

- (void)dismissOtherRequest
{
    [_otherRequestPopover close];
}

- (BOOL)isCurrentUser:(NSString *)userToTest
{
    return [[_helpSpot.staff nameForEmail:[[FFSSettings sharedSettings] helpSpotUsername]] isEqualToString:userToTest];
}

- (void)_loadingDidFinish:(NSNotification *)note
{
    // This notification can come from an individual request, in which case we just refresh that request, or from a filter, in which case we make changes to the whole list.
    if ( [note.userInfo objectForKey:@"request"] )
    {
        FHSRequest *request = [note.userInfo objectForKey:@"request"];
        [_requestList reloadItem:request];
        NSInteger i = [_requestList rowForItem:request];
        [_requestList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:i] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
        if ( [_requestController.request.requestID isEqual:request.requestID] )
        {
            [_requestController updateRequestViews];
        }
    }
    else if ( _helpSpot.inboxFilter.fetchInProgress == NO && _helpSpot.myQueueFilter.fetchInProgress == NO && _helpSpot.subscriptionFilter.fetchInProgress == NO )
    {
        if ( !_hasUpdated )
        {
            for ( FHSRequest *request in _helpSpot.allRequests )
            {
                request.justAdded = NO;
            }
            [_requestList reloadData];
            [_requestList expandItem:nil expandChildren:YES];
            _hasUpdated = YES;
        }
        else
        {
            int i = 0;
            id item = nil;
            
            [_requestList beginUpdates];
            
            // Remove rows for any requests that disappear.
            [self _removeRowsForRequestsInFilter:_helpSpot.inboxFilter];
            [self _removeRowsForRequestsInFilter:_helpSpot.myQueueFilter];
            [self _removeRowsForRequestsInFilter:_helpSpot.subscriptionFilter];
            
            // Add rows for any new requests.
            [self _addRowsForNewRequestsInFilter:_helpSpot.inboxFilter];
            [self _addRowsForNewRequestsInFilter:_helpSpot.myQueueFilter];
            [self _addRowsForNewRequestsInFilter:_helpSpot.subscriptionFilter];
            
            [_requestList endUpdates];
            
            // Refresh each old request individually (to update title, unread status, etc.)
            for ( i = 0; i < _requestList.numberOfRows; i++ )
            {
                item = [_requestList itemAtRow:i];
                if ( ![item isKindOfClass:[FHSRequest class]] ) continue;
                [_requestList reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:i] columnIndexes:[NSIndexSet indexSetWithIndex:0]];
            }
        }
        
        [self _setBadgeLabelWithUnreadCount];
    }
}

- (void)_requestNotFound:(NSNotification *)note
{
    FHSRequest *request = [note.userInfo objectForKey:@"request"];
    if ( [_requestController.request.requestID isEqual:request.requestID] )
    {
        [self _pushRequest:nil];
    }
}

- (void)_statusTypesDidUpdate:(NSNotification *)note
{
    [_requestController updateCloseAsPopUpWithStatusTypes:[note.userInfo objectForKey:@"statusTypes"]];
}

- (void)_authenticationNeeded:(NSNotification *)note
{
    [self showPreferences:self];
}

- (void)_addRowsForNewRequestsInFilter:(FHSFilter *)filter
{
    int i = 0;
    for ( NSString *requestID in filter.sortedRequestIDs )
    {
        FHSRequest *request = [filter.requests objectForKey:requestID];
        if ( request.justAdded )
        {
            [_requestList insertItemsAtIndexes:[NSIndexSet indexSetWithIndex:i] inParent:filter withAnimation:NSTableViewAnimationEffectFade];
            request.justAdded = NO;
        }
        i++;
    }
}

- (void)_removeRowsForRequestsInFilter:(FHSFilter *)filter
{
    NSArray *expiredRequestIDsSortedByDescendingIndex = [filter.expiredRequestIndexes keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj2 compare:obj1];
    }];
    for ( NSString *requestID in expiredRequestIDsSortedByDescendingIndex )
    {
        if ( _requestController.request == [filter.expiredRequests objectForKey:requestID] )
            [self _pushRequest:nil];
        
        if ( [_requestList rowForItem:[filter.expiredRequests objectForKey:requestID]] == NSNotFound )
            return;
        
        NSInteger indexInParent = [[filter.expiredRequestIndexes objectForKey:requestID] integerValue];
        
        // Before we remove this, make sure we've got the request we want. 
        NSInteger parentRow = [_requestList rowForItem:filter];
        id itemInTable = [_requestList itemAtRow:parentRow + indexInParent + 1];
        if ( [itemInTable isKindOfClass:[FHSRequest class]] && [[(FHSRequest *)itemInTable requestID] isEqualToString:requestID] )
            [_requestList removeItemsAtIndexes:[NSIndexSet indexSetWithIndex:indexInParent] inParent:filter withAnimation:NSTableViewAnimationEffectFade | NSTableViewAnimationSlideLeft];
        else
            NSLog( @"throttled duplicate removal" );        //// TEMP
    }
}

- (void)_pushRequest:(FHSRequest *)request
{
    if ( request )
    {
        _oldRequestController = _requestController;
        _requestController = [[RequestController alloc] init];
        _requestController.request = request;
        
        [NSBundle loadNibNamed:@"Request" owner:_requestController];
        _requestController.containerView.frame = [self _frameForRequestView];
        [_containerView addSubview:_requestController.containerView];
        
        NSPoint origin = _requestView.frame.origin;
        [_requestController.containerView setFrameOrigin:NSMakePoint( origin.x + _requestView.frame.size.width + 50, origin.y )];
        
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self _finishedPushingRequest];
        }];
        [_requestView.animator setFrameOrigin:NSMakePoint( origin.x - _requestView.frame.size.width - 50, origin.y )];
        [_requestView.animator setAlphaValue:0.0];
        _requestView = _requestController.containerView;
        [_requestView.animator setFrame:[self _frameForRequestView]];
        [_requestView.animator setAlphaValue:1.0];
    }
    else
    {
        if ( _requestController == nil ) return;
        
        _oldRequestController = _requestController;
        _requestController = nil;
        [NSBundle loadNibNamed:@"RequestNotFound" owner:self];
        _requestNotFoundView.frame = [self _frameForRequestView];
        [_containerView addSubview:_requestNotFoundView];
        
        [[NSAnimationContext currentContext] setDuration:0.2];
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [self _finishedPushingRequest];
        }];
        [_requestView.animator setFrameOrigin:NSMakePoint( _requestView.frame.origin.x - _requestView.frame.size.width - 50, _requestView.frame.origin.y )];
        [_requestView.animator setAlphaValue:0.0];
        _requestView = _requestNotFoundView;
        [_noRequestView.animator setAlphaValue:1.0];
    }
}

- (void)_finishedPushingRequest
{
    [_oldRequestController.containerView removeFromSuperview];
    _oldRequestController = nil;
}

- (NSRect)_frameForRequestView
{
    return NSInsetRect( _containerView.bounds, 20, 20 );
}

- (void)_setBadgeLabelWithUnreadCount
{
    NSInteger unreadCount = _helpSpot.totalUnreadCount;
    [[NSApp dockTile] setBadgeLabel:( unreadCount == 0 ? @"" : [NSString stringWithFormat:@"%ld", unreadCount] )];
}

#pragma mark - NSOutlineViewDataSource/Delegate

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    if ( item == nil )
        return 3;
    if ( [item isKindOfClass:[FHSFilter class]] )
    {
        FHSFilter *filter = (FHSFilter *)item;
        return filter.requests.count + filter.expiredRequests.count;
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    if ( item == nil )
    {
        if ( index == 0 )
            return _helpSpot.inboxFilter;
        if ( index == 1 )
            return _helpSpot.myQueueFilter;
        if ( index == 2 )
            return _helpSpot.subscriptionFilter;
        return nil;
    }
    if ( [item isKindOfClass:[FHSFilter class]] )
    {
        FHSFilter *filter = (FHSFilter *)item;
        return [filter.requests objectForKey:[filter.sortedRequestIDs objectAtIndex:index]];
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    if ( item == nil )
        return YES;
    if ( [item isKindOfClass:[FHSFilter class]] )
        return YES;
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldCollapseItem:(id)item
{
    return NO;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    if ( [item isKindOfClass:[FHSFilter class]] )
    {
        return [(FHSFilter *)item filterName];
    }
    else if ( [item isKindOfClass:[FHSRequest class]] )
    {
        return [(FHSRequest *)item title];
    }
    return @"";
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    return ( [item isKindOfClass:[FHSFilter class]] );
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    if ( [item isKindOfClass:[FHSFilter class]] )
    {
        NSTableCellView *view = [outlineView makeViewWithIdentifier:@"FilterHeaderCell" owner:self];
        FHSFilter *filter = (FHSFilter *)item;
        view.textField.stringValue = filter.filterName.uppercaseString;
        return view;
    }
    else if ( [item isKindOfClass:[FHSRequest class]] )
    {
        RequestCellView *view = [outlineView makeViewWithIdentifier:@"RequestDataCell" owner:self];
        FHSRequest *request = (FHSRequest *)item;
        view.subjectField.stringValue = request.title ? request.title : @"…";
        view.subjectField.font = [NSFont systemFontOfSize:12];
        view.requestNumberField.stringValue = request.requestID;
        view.requestNumberField.font = [NSFont systemFontOfSize:9];
        view.fromField.stringValue = request.customerName ? request.customerName : @"";
        view.fromField.font = [NSFont systemFontOfSize:9];
        
        float requestNumberWidth = view.requestNumberField.attributedStringValue.size.width;
        
        view.subjectField.frame = NSMakeRect( 14, 16, view.frame.size.width - 14, 17 );
        view.requestNumberField.frame = NSMakeRect( 14, 0, requestNumberWidth + 5, 17 );
        view.fromField.frame = NSMakeRect( 20 + requestNumberWidth, 0, view.frame.size.width - 20 - requestNumberWidth, 17 );

        if ( request.unread || request.filter.isInbox )
        {
            view.unreadImage.hidden = NO;
            view.unreadImage.frame = NSMakeRect( 0, 11, 14, 14 );
        }
        else
        {
            view.unreadImage.hidden = YES;
        }
        return view;
    }
    return nil;
}

- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
    return ( [item isKindOfClass:[FHSRequest class]] ? 35 : 17 );
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    [self _pushRequest:[_requestList itemAtRow:_requestList.selectedRow]];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    return [item isKindOfClass:[FHSRequest class]];
}

#pragma mark - NSSplitViewDelegate

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return MAX( proposedMinimumPosition, 120.0 );
}

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return MIN( proposedMaximumPosition, splitView.frame.size.width - 300.0 );
}

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    return YES;
}

- (NSRect)splitView:(NSSplitView *)splitView effectiveRect:(NSRect)proposedEffectiveRect forDrawnRect:(NSRect)drawnRect ofDividerAtIndex:(NSInteger)dividerIndex
{
    proposedEffectiveRect = drawnRect;
    proposedEffectiveRect.origin.x -= 3;
    proposedEffectiveRect.size.width += 6;
    return proposedEffectiveRect;
}

- (void)splitView:(NSSplitView *)splitView resizeSubviewsWithOldSize:(NSSize)oldSize
{
    NSView *sidebarView = [[splitView subviews] objectAtIndex:0];
    NSView *mainView = [[splitView subviews] objectAtIndex:1];
    
    NSRect sidebarRect = sidebarView.frame;
    sidebarRect.origin.y = splitView.frame.origin.y;
    sidebarRect.size.height = splitView.frame.size.height;
    if ( _sidebarWidthBeforeResizing > 0.0 )
        sidebarRect.size.width = _sidebarWidthBeforeResizing;
    
    NSRect mainRect = mainView.frame;
    mainRect.origin.y = splitView.frame.origin.y;
    mainRect.size.height = splitView.frame.size.height;
    mainRect.size.width = splitView.frame.size.width - mainRect.origin.x;
    
    if ( mainRect.size.width < 300.0 )
    {
        mainRect.size.width = 300.0;
        sidebarRect.size.width = splitView.frame.size.width - 300.0;
        mainRect.origin.x = sidebarRect.size.width;
    }
    
//    sidebarView.frame = sidebarRect;
//
    [splitView setPosition:sidebarRect.size.width ofDividerAtIndex:0];
    [[NSUserDefaults standardUserDefaults] setFloat:sidebarRect.size.width forKey:@"HelpifierSidebarWidth"];
    
    mainView.frame = mainRect;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
    if ( [notification.userInfo objectForKey:@"NSSplitViewDividerIndex"] )
    {
        self.sidebarWidthBeforeResizing = [[[_splitView subviews] objectAtIndex:0] frame].size.width;
        [[NSUserDefaults standardUserDefaults] setFloat:self.sidebarWidthBeforeResizing forKey:@"HelpifierSidebarWidth"];
    }
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ( [keyPath isEqualToString:@"lastError"] && object == _helpSpot )
    {
        if ( _helpSpot.lastError )
        {
            [[NSApp dockTile] setBadgeLabel:@"!"];
            [_otherRequestButton setEnabled:NO];
            [[NSAnimationContext currentContext] setDuration:0.3];
            [NSAnimationContext beginGrouping];
            [_warningImageView.animator setAlphaValue:1.0];
            _warningImageView.toolTip = _helpSpot.lastError;
            [_otherRequestButton.animator setAlphaValue:0.0];
            [NSAnimationContext endGrouping];
        }
        else
        {
            [self _setBadgeLabelWithUnreadCount];
            [_otherRequestButton setEnabled:YES];
            [[NSAnimationContext currentContext] setDuration:0.3];
            [NSAnimationContext beginGrouping];
            [_warningImageView.animator setAlphaValue:0.0];
            [_otherRequestButton.animator setAlphaValue:1.0];
            [NSAnimationContext endGrouping];
        }
    }
}

@end
