//
//  RequestViewController.m
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "RequestViewController.h"
#import "RequestsController.h"

@implementation RequestViewController

- (void) awakeFromNib
{
	_selectedRequest = nil;
}

- (void) dealloc
{
	self.selectedRequest = nil;
	[super dealloc];
}

@synthesize requestsController = _requestsController;
@synthesize fromTextField = _fromTextField;
@synthesize subjectTextField = _subjectTextField;
@synthesize bodyTextView = _bodyTextView;
@synthesize takeItButton = _takeItButton;
@synthesize viewItButton = _viewItButton;

- (HSRequest *) selectedRequest
{
	return _selectedRequest;
}

- (void) setSelectedRequest: (HSRequest *) newRequest
{
	if (newRequest == _selectedRequest) return;
	
	[self willChangeValueForKey:@"selectedRequest"];
	
	[_selectedRequest release];
	_selectedRequest = [newRequest retain];
	[_requestsController markAsSeen:_selectedRequest];
	
	if (_selectedRequest == nil)
	{
		[_fromTextField setStringValue:@""];
		[_subjectTextField setStringValue:@""];
		[_bodyTextView setString:@""];
		[_takeItButton setEnabled:NO];
		[_viewItButton setEnabled:NO];
	}
	else
	{
		[_fromTextField setStringValue:[NSString stringWithFormat:@"From: %@ (%@)", [_selectedRequest fullName], [_selectedRequest email]]];
		[_subjectTextField setStringValue:[_selectedRequest title]];
		[_bodyTextView setString:[_selectedRequest body]];
		[_takeItButton setEnabled:([_selectedRequest valueForKey:@"xPersonAssignedTo"] == nil)];
		[_viewItButton setEnabled:YES];
	}
	
	[self didChangeValueForKey:@"selectedRequest"];
}

- (IBAction) takeIt: (id) sender
{
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"http://figure53.com/support/admin.php?pg=HSRequest&reqid=%d&frominbox=1&rand=%d\"", [_selectedRequest requestID], random()]] autorelease];
	[script executeAndReturnError:nil];
}

- (IBAction) viewRequest: (id) sender
{
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"http://figure53.com/support/admin.php?pg=HSRequest&reqid=%d\"", [_selectedRequest requestID]]] autorelease];
	[script executeAndReturnError:nil];
}

@end
