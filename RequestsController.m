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

@end


#pragma mark -

@implementation RequestsController

- (void) awakeFromNib
{
	_attentionRequest = 0;
	_inboxParentItem = [@"Inbox" retain];
	_inboxRequests = [NSMutableDictionary new];
	_myQueueParentItem = [@"My Queue" retain];
	_myQueueRequests = [NSMutableDictionary new];
	_numberOfHistoryItemsByRequestID = [NSMutableDictionary new];
	_refreshMutex = [NSObject new];
	_refreshTimer = [NSTimer scheduledTimerWithTimeInterval:kRefreshIntervalInSeconds target:self selector:@selector(refreshRequests:) userInfo:nil repeats:YES];
	[_requestsOutlineView expandItem:nil expandChildren:YES];
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

- (id) selection
{
	return [_requestsOutlineView itemAtRow:[_requestsOutlineView selectedRow]];
}

- (void) setSelection: (id) newSelection
{
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
			return [_inboxRequests objectForKey:[[_inboxRequests allKeys] objectAtIndex:index]];
		}
		else if (item == _myQueueParentItem)
		{
			return [_myQueueRequests objectForKey:[[_myQueueRequests allKeys] objectAtIndex:index]];
		}
	}
	return nil;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	return ([item isKindOfClass:[NSString class]]);
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
		else if ([item isKindOfClass:[HSRequest class]])
		{
			if ([[tableColumn identifier] isEqual:@"requestShortSummary"])
				return [NSString stringWithFormat:@"%@%d%@ - %@", ([(HSRequest *)item isUnread] ? @"* " : @""), [(HSRequest *)item requestID], ([(HSRequest *)item urgent] ? @"(!!)" : @""), [(HSRequest *)item title]];
			else if ([[tableColumn identifier] isEqual:@"requestNumber"])
				return [NSString stringWithFormat:@"%d", [(HSRequest *)item requestID]];
			else if ([[tableColumn identifier] isEqual:@"subject"])
				return [(HSRequest *)item title];
			else if ([[tableColumn identifier] isEqual:@"body"])
				return [(HSRequest *)item body];
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
	[_requestViewController setSelectedRequest:[self selection]];
	[self didChangeValueForKey:@"selection"];
}

- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item
{
	if ([item isKindOfClass:[NSString class]]) return YES;
	return NO;
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	if ([item isKindOfClass:[HSRequest class]]) return YES;
	return NO;
}

- (NSCell *)outlineView:(NSOutlineView *)outlineView dataCellForTableColumn:(NSTableColumn *)tableColumn item:(id)item
{
	NSCell *cell = [tableColumn dataCellForRow:[outlineView rowForItem:item]];
	if (![item isKindOfClass:[HSRequest class]]) return cell;
	if ([(HSRequest *)item isUnread])
		[cell setFont:[NSFont boldSystemFontOfSize:[NSFont smallSystemFontSize]]];
	else
		[cell setFont:[NSFont systemFontOfSize:[NSFont smallSystemFontSize]]];
	return cell;
}

@end


#pragma mark -


@implementation RequestsController (Private)

- (void) updateDictionary: (NSMutableDictionary *) dict withRequestsFromFilter: (HSFilter *) filter
{
	NSDictionary *dictCopy = [[dict copy] autorelease];
	[dict removeAllObjects];
	
	NSError *error = nil;
	NSArray *requests = [filter requests:&error];
	if (requests == nil)
	{
		NSAlert *alert = [NSAlert alertWithError:error];
		[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
	}
	else
	{
		for (HSRequest *request in requests)
		{
			if ([request requestID] == 0) continue;
			HSRequest *fullRequest = [HSRequest requestWithID:[request requestID] error:&error];
			if (fullRequest == nil)
			{
				NSAlert *alert = [NSAlert alertWithError:error];
				[alert setMessageText:[NSString stringWithFormat:@"Unable to get request #%d.", [request requestID]]];
				[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:YES];
			}
			else
			{
				NSNumber *reqID = [NSNumber numberWithUnsignedInt:[request requestID]];
				[dict setObject:fullRequest forKey:reqID];
//				if (![fullRequest isUnread])
//					[_numberOfHistoryItemsByRequestID removeObjectForKey:reqID];
			}
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
	
	@synchronized ([userInfo objectForKey:@"mutex"])
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
				NSAlert *alert = [NSAlert alertWithError:error];
				[alert performSelectorOnMainThread:@selector(runModal) withObject:nil waitUntilDone:NO];
			}
		}
		else
		{
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
	}
	
	[_refreshProgressIndicator stopAnimation:self];
	[_refreshButton setEnabled:YES];
	[_refreshButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
	[_refreshProgressIndicator setHidden:YES];
	
	BOOL needsUserAttention = NO;
	for (NSNumber *reqID in [_inboxRequests allKeys])
	{
		if ([_numberOfHistoryItemsByRequestID objectForKey:reqID] == nil)
		{	
			needsUserAttention = YES;
		}
		[_numberOfHistoryItemsByRequestID setObject:[NSNumber numberWithInteger:[[_inboxRequests objectForKey:reqID] numberOfHistoryItems]] forKey:reqID];
	}
	for (NSNumber *reqID in [_myQueueRequests allKeys])
	{
		if ([[_myQueueRequests objectForKey:reqID] isUnread] && [_numberOfHistoryItemsByRequestID objectForKey:reqID] == nil)
		{	
			needsUserAttention = YES;
		}
		[_numberOfHistoryItemsByRequestID setObject:[NSNumber numberWithInteger:[[_myQueueRequests objectForKey:reqID] numberOfHistoryItems]] forKey:reqID];
	}
	
	if (needsUserAttention)
		_attentionRequest = [NSApp requestUserAttention:NSCriticalRequest];
	else if (!hasAnyUnreadRequests && _attentionRequest > 0)	// stop bouncing if, say, the inbox just got cleared
	{	
		[NSApp cancelUserAttentionRequest:_attentionRequest];
		_attentionRequest = 0;
	}
	
	[self performSelectorOnMainThread:@selector(reloadOutlineView) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void) reloadOutlineView
{
	[_requestsOutlineView reloadItem:nil reloadChildren:YES];
}

@end
