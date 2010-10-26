//
//  RequestsController.m
//  Helpifier
//
//  Created by Sean Dougall on 9/27/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "RequestsController.h"
#import "RequestViewController.h"
#import "ApplicationDelegate.h"

#define kRefreshIntervalInSeconds 20


#pragma mark -

@interface RequestsController (Private)

- (void) updateDictionary: (NSMutableDictionary *) dict withRequestsFromFilter: (HSFilter *) filter;
- (void) performRefreshRequests: (NSDictionary *) userInfo;
- (void) reloadOutlineView;
- (void) reloadSelectedRequest;
- (void) updateSelection;
- (void) updateOutlineViewSelection;
- (HSRequest *) requestForKey: (id) key;

@end


#pragma mark -

@implementation RequestsController

- (void) awakeFromNib
{
    _hasLoadedOutlineView = NO;
    _attentionRequest = 0;
    _inboxParentItem = [@"Inbox" retain];
    _inboxRequests = [NSMutableDictionary new];
    _myQueueParentItem = [@"My Queue" retain];
    _myQueueRequests = [NSMutableDictionary new];
    _numberOfHistoryItemsByRequestID = [NSMutableDictionary new];
    _refreshMutex = [NSObject new];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSelectedRequest) name:@"HSRequestDidUpdateNotification" object:nil];
    
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshIntervalInSeconds target:self selector:@selector(refreshRequests:) userInfo:nil repeats:YES];
    [self performSelector:@selector(refreshRequests:) withObject:self afterDelay:2];
}

- (void) dealloc
{
    [_refreshTimer invalidate];
    _refreshTimer = nil;
    
    [_inboxRequests release];
    _inboxRequests = nil;
    
    [_myQueueRequests release];
    _myQueueRequests = nil;
    
    [_numberOfHistoryItemsByRequestID release];
    _numberOfHistoryItemsByRequestID = nil;
    
    [_refreshMutex release];
    _refreshMutex = nil;
    
    [_inboxParentItem release];
    _inboxParentItem = nil;
    
    [_myQueueParentItem release];
    _myQueueParentItem = nil;
    
    [super dealloc];
}

@synthesize requestsOutlineView = _requestsOutlineView;
@synthesize requestViewController = _requestViewController;
@synthesize refreshButton = _refreshButton;
@synthesize refreshProgressIndicator = _refreshProgressIndicator;

@synthesize offlineError = _offlineError;

- (HSRequest *) selection
{
    return [self requestForKey:[NSNumber numberWithInteger:_selectedRequestID]];
}

- (void) setSelection: (HSRequest *) newSelection
{
    if (newSelection == nil)
        _selectedRequestID = 0;
    else
        _selectedRequestID = [newSelection requestID];
    
    [self updateOutlineViewSelection];
}

- (IBAction) refreshRequests: (id) sender
{
    [NSThread detachNewThreadSelector:@selector(performRefreshRequests:) toTarget:self withObject:[NSDictionary dictionaryWithObjectsAndKeys:_refreshMutex, @"mutex", nil]];
}

#pragma mark -
#pragma mark outline view data source

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if (item == nil)
        {
            switch (index)
            {
                case 0: return _inboxParentItem;
                case 1: return _myQueueParentItem;
                default: return nil;
            }
        }
        else if (item == _inboxParentItem)
        {
            return [[[[_inboxRequests allKeys] objectAtIndex:index] copy] autorelease];
        }
        else if (item == _myQueueParentItem)
        {
            return [[[[_myQueueRequests allKeys] objectAtIndex:index] copy] autorelease];
        }
    }
    return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
    @synchronized (_refreshMutex)
    {
        if ([item isKindOfClass:[NSString class]]) return YES;
    }
    return NO;
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if (item == nil)
            return 2;
        if (item == _inboxParentItem)
            return [_inboxRequests count];
        if (item == _myQueueParentItem)
            return [_myQueueRequests count];
    }
    return 0;
}

- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if ([item isKindOfClass:[NSString class]])
        {
            if ([[tableColumn identifier] isEqual:@"requestShortSummary"])
                return [item uppercaseString];
            else
                return nil;
        }
        else if ([item isKindOfClass:[NSNumber class]])
        {
            HSRequest *req = [self requestForKey:item];
            if (req == nil) return @"...";
            
            @synchronized (req)
            {
                if ([[tableColumn identifier] isEqual:@"requestShortSummary"])
                    return [NSString stringWithFormat:@"%@%d%@ - %@", ([req isUnread] ? @"* " : @""), [req requestID], ([req urgent] ? @"(!!)" : @""), [req title]];
                else if ([[tableColumn identifier] isEqual:@"requestNumber"])
                    return [NSString stringWithFormat:@"%d", [req requestID]];
                else if ([[tableColumn identifier] isEqual:@"subject"])
                    return [req title];
                else if ([[tableColumn identifier] isEqual:@"body"])
                    return [req body];
                else
                    return nil;
            }
        }
    }
    return nil;
}


#pragma mark -
#pragma mark outline view delegate

- (void)outlineViewSelectionIsChanging:(NSNotification *)notification
{
    [self willChangeValueForKey:@"selection"];
}

- (void)outlineViewSelectionDidChange:(NSNotification *)notification
{
    @synchronized (_refreshMutex)
    {
        [self updateSelection];
        [_requestViewController setSelectedRequest:[self selection]];
        [self didChangeValueForKey:@"selection"];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if ([item isKindOfClass:[NSString class]]) return YES;
    }
    return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if ([item isKindOfClass:[NSNumber class]]) return YES;
    }
    return NO;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSCell *cell;
    @synchronized (_refreshMutex)
    {
        cell = [tableColumn dataCellForRow:[outlineView rowForItem:item]];
        if (![item isKindOfClass:[NSNumber class]]) return cell;
        HSRequest *req = [self requestForKey:item];
        @synchronized (req)
        {
            if ([req isUnread])
                [cell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
            else
                [cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
        }
    }
    return cell;
}

@end


#pragma mark -


@implementation RequestsController (Private)

- (void) updateDictionary: (NSMutableDictionary *) dict withRequestsFromFilter: (HSFilter *) filter
{
    NSMutableArray *requestIDsFound = [NSMutableArray array];
    
    NSError *error = nil;
    NSArray *requests = [filter requests:&error];
    if (requests == nil)
    {
        self.offlineError = error;
    }
    else
    {
        for (HSRequest *request in requests)
        {
            if ([request requestID] == 0) continue;
            
            NSNumber *reqID = [NSNumber numberWithInteger:[request requestID]];
            [requestIDsFound addObject:reqID];
            
            if ([[dict allKeys] containsObject:reqID])
                [[dict objectForKey:reqID] setIsUnread:[request isUnread]];
            else 
                [dict setObject:request forKey:reqID];
            
            [[dict objectForKey:reqID] get];
        }
    }
    
    @synchronized (_refreshMutex)
    {
        for (NSNumber *reqID in [NSArray arrayWithArray:[dict allKeys]])
        {
            if (![requestIDsFound containsObject:reqID])
                [dict removeObjectForKey:reqID];
        }
    }
}

- (void) performRefreshRequests: (NSDictionary *) userInfo
{
    if (![(ApplicationDelegate *)[NSApp delegate] workspaceInitialized]) 
    {
        NSLog(@"aborting refresh because workspace is not yet initialized");
        return;
    }
    NSAutoreleasePool *pool = [NSAutoreleasePool new];

    BOOL hasAnyUnreadRequests = NO;

    [_refreshButton setEnabled:NO];
    [_refreshButton setImage:nil];
    [_refreshProgressIndicator setHidden:NO];
    [_refreshProgressIndicator startAnimation:self];

    @synchronized (_refreshMutex)
    {
    //		[_newRequests removeAllObjects];
        
        NSError *error = nil;
        NSArray *filters = [HSFilter filters:&error];
        if (filters == nil)
        {
            if ([error code] == 2)
            {
                [(ApplicationDelegate *)[NSApp delegate] showPreferences:self];
            }
            else
            {
                self.offlineError = error;
            }
        }
        else
        {
            self.offlineError = nil;
            for (HSFilter *filter in filters)
            {
                if ([[filter filterName] isEqual:_inboxParentItem])
                {
                    [self updateDictionary:_inboxRequests withRequestsFromFilter:filter];
                    for (HSRequest *req in [_inboxRequests allValues])
                    {	
                        [req setIsUnread:YES];
                        hasAnyUnreadRequests = YES;
                    }
                }
                else if ([[filter filterName] isEqual:_myQueueParentItem])
                {
                    [self updateDictionary:_myQueueRequests withRequestsFromFilter:filter];
                    for (HSRequest *req in [_myQueueRequests allValues])
                        if ([req isUnread]) hasAnyUnreadRequests = YES;
                }
            }
        }
        [self reloadSelectedRequest];
    }

    [_refreshProgressIndicator stopAnimation:self];
    [_refreshButton setEnabled:YES];
    [_refreshButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
    [_refreshProgressIndicator setHidden:YES];
    
    BOOL needsUserAttention = NO;
    int numberOfUnreadRequests = 0;
    @synchronized (_refreshMutex)
    {
        for (NSNumber *reqID in [_inboxRequests allKeys])
        {
            numberOfUnreadRequests++;
            if ([_numberOfHistoryItemsByRequestID objectForKey:reqID] == nil)
            {	
                needsUserAttention = YES;
            }
            [_numberOfHistoryItemsByRequestID setObject:[NSNumber numberWithInteger:[[_inboxRequests objectForKey:reqID] numberOfHistoryItems]] forKey:reqID];
        }
        for (NSNumber *reqID in [_myQueueRequests allKeys])
        {
            if ([[_myQueueRequests objectForKey:reqID] isUnread])
            {
                numberOfUnreadRequests++;
                if ([_numberOfHistoryItemsByRequestID objectForKey:reqID] == nil)
                {	
                    needsUserAttention = YES;
                }
            }
            [_numberOfHistoryItemsByRequestID setObject:[NSNumber numberWithInteger:[[_myQueueRequests objectForKey:reqID] numberOfHistoryItems]] forKey:reqID];
        }
    }
    
    if (needsUserAttention)
    {
        _attentionRequest = [NSApp requestUserAttention:NSCriticalRequest];
        if ([[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"notificationSound"])
            [[NSSound soundNamed:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"notificationSound"]] play];
    }
    else if (!hasAnyUnreadRequests && _attentionRequest > 0)	// stop bouncing if, say, the inbox just got cleared
    {	
        [NSApp cancelUserAttentionRequest:_attentionRequest];
        _attentionRequest = 0;
    }

    if (numberOfUnreadRequests > 0)
        [[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%d", numberOfUnreadRequests]];
    else
        [[NSApp dockTile] setBadgeLabel:@""];
    
    [self performSelectorOnMainThread:@selector(reloadOutlineView) withObject:nil waitUntilDone:NO];

    [pool release];
}

- (void) reloadOutlineView
{
    [_requestsOutlineView reloadItem:nil reloadChildren:YES];
    if (![[_inboxRequests allKeys] containsObject:[NSNumber numberWithInteger:_selectedRequestID]]
        && ![[_myQueueRequests allKeys] containsObject:[NSNumber numberWithInteger:_selectedRequestID]])
        self.selection = nil;
    [self updateOutlineViewSelection];
    if (!_hasLoadedOutlineView)
        [_requestsOutlineView expandItem:nil expandChildren:YES];
    _hasLoadedOutlineView = YES;
}

- (void) reloadSelectedRequest
{
    [_requestViewController performSelectorOnMainThread:@selector(setSelectedRequest:) withObject:[self selection] waitUntilDone:NO];
}

- (void) updateSelection
{
    [self setSelection:[self requestForKey:[_requestsOutlineView itemAtRow:[_requestsOutlineView selectedRow]]]];
    [self reloadOutlineView];
}

- (void) updateOutlineViewSelection
{
    if (_selectedRequestID == 0)
        [_requestsOutlineView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    else
        [_requestsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_requestsOutlineView rowForItem:self.selection]] byExtendingSelection:NO];
}

- (HSRequest *) requestForKey: (id) key
{
    HSRequest *req = [_inboxRequests objectForKey:key];
    if (req == nil) req = [_myQueueRequests objectForKey:key];
    return req;
}

@end
