//
//  RequestController.m
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//
//	Copyright (c) 2010-2011 Figure 53 LLC, http://figure53.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
//

#import "RequestController.h"
#import "RequestViewController.h"
#import "Request.h"
#import "HelpifierAppDelegate.h"


#define kRefreshInterval 20.0


@interface RequestController (Private)

- (void) setupRootObject;
- (void) updateSelection;
- (void) updateOutlineViewSelection;
- (void) reloadOutlineView;
- (void) setIsBusyRefreshing: (BOOL) busy;
- (void) performRefreshFromTimer;
- (void) staffDidChange: (NSNotification *) note;

@end


@implementation RequestController (Private)

- (void) setupRootObject
{
    self.filters = [[[FilterCollection alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.user.getFilters", AppDelegate.apiURL]] autorelease];
    self.filters.delegate = self;
    self.subscriptions = nil;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(staffDidChange:) name:@"StaffDidChangeNotification" object:nil];
    [self refreshRequests:self];
}

- (void) updateSelection
{
    [self setSelection:[_requestsOutlineView itemAtRow:[_requestsOutlineView selectedRow]]];
    [self reloadOutlineView];
    [_requestViewController setSelectedRequest:self.selection];
}

- (void) updateOutlineViewSelection
{
    if (_selectedRequestID == 0)
        [_requestsOutlineView selectRowIndexes:[NSIndexSet indexSet] byExtendingSelection:NO];
    else
        [_requestsOutlineView selectRowIndexes:[NSIndexSet indexSetWithIndex:[_requestsOutlineView rowForItem:self.selection]] byExtendingSelection:NO];
}

- (void) reloadOutlineView
{
    [_requestsOutlineView reloadItem:nil reloadChildren:YES];
    
    BOOL selectedRequestStillExists = NO;
    for (NSString *filterName in _enabledFilterNames)
    {
        for (NSNumber *requestID in [[[_filters filterForID:filterName] requests] allKeys])
        {
            if ([requestID integerValue] == _selectedRequestID)
            {
                selectedRequestStillExists = YES;
                goto finished_searching_for_request_id;
            }
        }
    }

    for (NSNumber *requestID in [[_subscriptions requests] allKeys])
    {
        if ([requestID integerValue] == _selectedRequestID)
        {
            selectedRequestStillExists = YES;
            goto finished_searching_for_request_id;
        }
    }
    
finished_searching_for_request_id:
    if (!selectedRequestStillExists)
        self.selection = nil;
    
    [self updateOutlineViewSelection];
    if (!_hasLoadedOutlineView)
        [_requestsOutlineView expandItem:nil expandChildren:YES];
    _hasLoadedOutlineView = YES;
}

- (void) performRefreshFromTimer
{
    [self refreshRequests:self];
}

- (void) setIsBusyRefreshing: (BOOL) busy
{
    if (busy)
    {
        [_refreshButton setEnabled:NO];
        [_refreshButton setImage:nil];
        [_refreshProgressIndicator setHidden:NO];
        [_refreshProgressIndicator startAnimation:self];
    }
    else
    {
        [_refreshProgressIndicator stopAnimation:self];
        [_refreshProgressIndicator setHidden:YES];
        [_refreshButton setEnabled:YES];
        [_refreshButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
    }
}

- (void) staffDidChange: (NSNotification *) note
{
    self.subscriptions = [[[SubscriptionFilter alloc] initWithPath:[NSString stringWithFormat:@"%@index.php?method=private.request.subscriptions&xPerson=%@", AppDelegate.apiURL, [[[Staff staff] personWithEmail:AppDelegate.username] objectForKey:@"xPerson"]]] autorelease];
    self.subscriptions.delegate = self;
    [self.subscriptions beginFetch];
}

@end



#pragma mark -

@implementation RequestController

@synthesize filters = _filters;
@synthesize subscriptions = _subscriptions;
@synthesize enabledFilterNames = _enabledFilterNames;
@synthesize offlineError = _offlineError;
@synthesize requestsOutlineView = _requestsOutlineView;
@synthesize refreshButton = _refreshButton;
@synthesize refreshProgressIndicator = _refreshProgressIndicator;
@synthesize requestViewController = _requestViewController;
@synthesize isLoadingOtherRequest = _isLoadingOtherRequest;

- (void) awakeFromNib
{
    _refreshMutex = [NSObject new];
    self.enabledFilterNames = [NSMutableArray arrayWithObjects:@"inbox", @"myq", nil];
    _requestsWithPendingFetches = [[NSMutableArray array] retain];
    _isRefreshingByUserCommand = NO;
    [self setupRootObject];
    _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(performRefreshFromTimer) userInfo:nil repeats:YES];
    
    [[NSUserDefaultsController sharedUserDefaultsController] addObserver:self forKeyPath:@"values.apiURL" options:NSKeyValueObservingOptionNew context:@selector(setupRootObject)];
}

- (void) dealloc
{
    [_refreshMutex release];
    _refreshMutex = nil;
    
    [_requestsWithPendingFetches release];
    _requestsWithPendingFetches = nil;
    
    self.filters = nil;
    self.subscriptions = nil;
    self.offlineError = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

- (void) dataObjectDidFinishFetch: (DataObject *) obj
{
    self.offlineError = nil;
    
    if (obj == self.filters)    // FilterCollection finished; start fetching each individual filter.
    {
        for (NSString *name in _enabledFilterNames)
        {
            ((Filter *)[self.filters.filters objectForKey:name]).delegate = self;
            [[self.filters.filters objectForKey:name] beginFetch];
        }
    }
    else if ([obj isKindOfClass:[SubscriptionFilter class]])
    {
        for (Request *request in [(SubscriptionFilter *)obj sortedRequests])
        {
            [_requestsWithPendingFetches addObject:[NSNumber numberWithInteger:request.requestID]];
            [request.properties setObject:@"SUBSCRIPTIONS" forKey:@"filterID"];
            request.delegate = self;
            [request beginFetch];
        }
    }
    else if ([obj isKindOfClass:[Filter class]])    // Filter finished; start fetching individual requests.
    {
        for (Request *request in [(Filter *)obj sortedRequests])
        {
            [_requestsWithPendingFetches addObject:[NSNumber numberWithInteger:request.requestID]];
            [request.properties setObject:[((Filter *)obj).properties objectForKey:@"xFilter"] forKey:@"filterID"];
            request.delegate = self;
            [request beginFetch];
        }
    }
    else if ([obj isKindOfClass:[Request class]])
    {
        Request *request = (Request *)obj;
        
        [_requestsWithPendingFetches removeObject:[NSNumber numberWithInteger:request.requestID]];
        if ([_requestsWithPendingFetches count] == 0)
        {
            // Do all this when the last request is finished loading
            [self setIsBusyRefreshing:NO];
            if (!_isLoadingOtherRequest)
                [self reloadOutlineView];

            NSMutableDictionary *unread = [NSMutableDictionary dictionary];
            for (Filter *filter in [_filters.filters allValues])
            {
                for (Request *request in [filter.requests allValues])
                {
                    if (request.isUnread || [[filter.properties objectForKey:@"xFilter"] isEqual:@"inbox"])
                        [unread setObject:request.lastReplyDate forKey:[NSNumber numberWithInteger:request.requestID]];
                }
            }
            [AppDelegate setUnreadRequests:unread notify:!_isRefreshingByUserCommand];
            _isRefreshingByUserCommand = NO;
        }
    }
    self.offlineError = nil;
}

- (void) dataObjectDidFailFetchWithError: (NSString *) err
{
    [_requestsWithPendingFetches removeAllObjects];
    [self setIsBusyRefreshing:NO];
    
    self.offlineError = err;
}

- (Request *) selection
{
    return [self requestForID:[NSString stringWithFormat:@"%d", _selectedRequestID]];
}

- (void) setSelection: (Request *) newSelection
{
    if (newSelection == nil)
        _selectedRequestID = 0;
    else
        _selectedRequestID = [newSelection requestID];
    
    [self updateOutlineViewSelection];
}

- (Request *) requestForID: (id) inID
{
    for (Request *request in [_subscriptions.requests allValues])
    {
        if ([[NSString stringWithFormat:@"%@", [request.properties objectForKey:@"xRequest"]] isEqual:[NSString stringWithFormat:@"%@", inID]])
            return request;
    }
    
    for (Filter *filter in [_filters.filters allValues])
    {
        for (Request *request in [filter.requests allValues])
        {
            if ([[NSString stringWithFormat:@"%@", [request.properties objectForKey:@"xRequest"]] isEqual:[NSString stringWithFormat:@"%@", inID]])
                return request;
        }
    }
    
    return nil;
}

- (IBAction) refreshRequests: (id) sender
{
    if ([_requestsWithPendingFetches count] > 0)
    {
        if (sender != self)     // Note: we shouldn't actually get here
            NSRunAlertPanel(@"Fetch in progress.", @"A fetch is already in progress. Please try again in a moment.", @"OK", nil, nil);
        
        return;
    }
    
    if (sender != self)
    {
        _isRefreshingByUserCommand = YES;
        [_refreshTimer invalidate];
        _refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshInterval target:self selector:@selector(performRefreshFromTimer) userInfo:nil repeats:YES];
    }
    
    [self setIsBusyRefreshing:YES];
    self.isLoadingOtherRequest = NO;
    
    [self.filters beginFetch];
    [self.subscriptions beginFetch];
}

- (IBAction) selectOtherRequest: (id) sender
{
    Request *request = [[[Request alloc] initOtherRequestWithRequestID:[sender integerValue]] autorelease];
    [_requestsWithPendingFetches addObject:[NSNumber numberWithInteger:request.requestID]];
    request.delegate = self;
    self.isLoadingOtherRequest = YES;
    [request beginFetch];
}

#pragma mark -
#pragma mark split view delegate

- (BOOL) splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview
{
	if ([subview isEqual:[[splitView subviews] objectAtIndex:0]])
		return NO;
	
	return YES;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMin ofSubviewAt:(NSInteger)dividerIndex
{
	return 200;
}

- (CGFloat) splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMax ofSubviewAt:(NSInteger)dividerIndex
{
	return [splitView maxPossiblePositionOfDividerAtIndex:dividerIndex] - 450;
}

#pragma mark -
#pragma mark outline view data source

- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
    @synchronized (_refreshMutex)
    {
        if (item == nil)
        {
            if (index == [self.enabledFilterNames count])
            {
                if ([[[Staff staff] people] count] == 0)
                    return nil;
                else
                    return @"SUBSCRIPTIONS";
            }
            else if (index >= 0 && index < [self.enabledFilterNames count])
            {
                return [self.enabledFilterNames objectAtIndex:index];
            }
            
            return nil;
        }
        else
        {
            if ([item isEqual:@"SUBSCRIPTIONS"])
            {
                NSArray *requests = [_subscriptions sortedRequests];
                if (index >= 0 && index < [requests count])
                    return [requests objectAtIndex:index];
                else
                    return nil;
            }
            else
            {
                NSArray *requests = [[_filters filterForID:item] sortedRequests];
                if (index >= 0 && index < [requests count])
                    return [requests objectAtIndex:index];
                else
                    return nil;
            }
        }
    }
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
        {
            if ([[_subscriptions requests] count] > 0)
                return 3;
            else
                return 2;
        }
        
        if ([item isEqual:@"SUBSCRIPTIONS"])
            return [[_subscriptions requests] count];
        
        Filter *filter = [_filters filterForID:item];
        if (filter)
            return [[filter requests] count];
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
            {
                Filter *filter = [_filters filterForID:item];
                if (filter)
                    return [[filter.properties objectForKey:@"sFilterName"] uppercaseString];
                return [item uppercaseString];
            }
            else
                return nil;
        }
        else if ([item isKindOfClass:[Request class]])
        {
            Request *req = (Request *)item;
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
        if ([item isKindOfClass:[Request class]]) return YES;
    }
    return NO;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
    NSCell *cell;
    @synchronized (_refreshMutex)
    {
        cell = [tableColumn dataCellForRow:[outlineView rowForItem:item]];
        if (![item isKindOfClass:[Request class]]) return cell;
        Request *req = (Request *)item;
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

#pragma mark -
#pragma mark KVO

- (void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([self respondsToSelector:(SEL)context])
        [self performSelector:(SEL)context];
    else
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

@end
