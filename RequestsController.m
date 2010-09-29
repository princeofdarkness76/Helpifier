//
//  RequestsController.m
//  Helpifier
//
//  Created by Sean Dougall on 9/27/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "RequestsController.h"
#import "RequestViewController.h"
#import "HSRequestAdditions.h"
#import "ApplicationDelegate.h"
#import <HelpSpot/HelpSpot.h>

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
	_inboxParentItem = [@"Inbox" retain];
	_inboxRequests = [NSMutableDictionary new];
	_myQueueParentItem = [@"My Queue" retain];
	_myQueueRequests = [NSMutableDictionary new];
	_newRequests = [NSMutableArray new];
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
	
	[_newRequests release];
	_newRequests = nil;
	
	[_refreshMutex release];
	_refreshMutex = nil;
	
	[_inboxParentItem release];
	_inboxParentItem = nil;
	
	[_myQueueParentItem release];
	_myQueueParentItem = nil;
	
	[_numberOfHistoryItemsByRequestID release];
	_numberOfHistoryItemsByRequestID = nil;
	
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
				return [NSString stringWithFormat:@"%@%d%@ - %@", ([(HSRequest *)item hasUnseenHistory] ? @"* " : @""), [(HSRequest *)item requestID], ([(HSRequest *)item urgent] ? @"(!!)" : @""), [(HSRequest *)item title]];
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
	if ([(HSRequest *)item hasUnseenHistory])
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
		[alert runModal];
	}
	else
	{
		for (HSRequest *HSRequest in requests)
		{
			if ([HSRequest requestID] == 0) continue;
			NSNumber *reqID = [NSNumber numberWithUnsignedInt:[HSRequest requestID]];
			[dict setObject:HSRequest forKey:reqID];
			if ([dictCopy objectForKey:reqID] == nil || [HSRequest numberOfHistoryItems] != [[_numberOfHistoryItemsByRequestID objectForKey:[NSNumber numberWithUnsignedInteger:reqID]] unsignedIntegerValue])
			{	
				[_newRequests addObject:HSRequest];
				[_numberOfHistoryItemsByRequestID setObject:[NSNumber numberWithUnsignedInteger:[HSRequest numberOfHistoryItems]] forKey:[NSNumber numberWithUnsignedInteger:reqID]];
				HSRequest.hasUnseenHistory = YES;
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
	
	[_refreshButton setEnabled:NO];
	[_refreshButton setImage:nil];
	[_refreshProgressIndicator setHidden:NO];
	[_refreshProgressIndicator startAnimation:self];
	
	@synchronized ([userInfo objectForKey:@"mutex"])
	{
		[_newRequests removeAllObjects];
		
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
				[alert runModal];
			}
		}
		else
		{
			for (HSFilter *filter in filters)
			{
				if ([[filter filterName] isEqual:_inboxParentItem])
				{
					[self updateDictionary:_inboxRequests withRequestsFromFilter:filter];
				}
				else if ([[filter filterName] isEqual:_myQueueParentItem])
				{
					[self updateDictionary:_myQueueRequests withRequestsFromFilter:filter];
				}
			}
		}
	}
	
	[_refreshProgressIndicator stopAnimation:self];
	[_refreshButton setEnabled:YES];
	[_refreshButton setImage:[NSImage imageNamed:@"NSRefreshTemplate"]];
	[_refreshProgressIndicator setHidden:YES];
	
	if ([_newRequests count] > 0)
		[NSApp requestUserAttention:NSCriticalRequest];
	
	[self performSelectorOnMainThread:@selector(reloadOutlineView) withObject:nil waitUntilDone:NO];
	
	[pool release];
}

- (void) reloadOutlineView
{
	[_requestsOutlineView reloadItem:nil reloadChildren:YES];
}

@end
