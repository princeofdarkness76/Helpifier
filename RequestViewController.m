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
//@synthesize bodyTextView = _bodyTextView;
@synthesize bodyHTMLView = _bodyHTMLView;
@synthesize takeItButton = _takeItButton;
@synthesize viewItButton = _viewItButton;

- (HSRequest *) selectedRequest
{
	return _selectedRequest;
}

- (void) setSelectedRequest: (HSRequest *) newRequest
{
	NSError *err = nil;
	
	[self willChangeValueForKey:@"selectedRequest"];
	
	[_selectedRequest release];
//	_selectedRequest = [[HSRequest requestWithID:[newRequest requestID] error:&err] retain];
	_selectedRequest = [newRequest retain];
	
	[_fromTextField setStringValue:@""];
	[_subjectTextField setStringValue:(_selectedRequest == nil ? @"" : @"Loading request...")];
//	[_bodyTextView setString:@""];
	[_takeItButton setEnabled:NO];
	[_viewItButton setEnabled:NO];
	
	if (_selectedRequest != nil)
	{
		[_fromTextField setStringValue:[NSString stringWithFormat:@"From: %@ (%@)", [_selectedRequest fullName], [_selectedRequest email]]];
		NSString *subject = [_selectedRequest title];
		[_subjectTextField setStringValue:(subject == nil ? @"(no subject)" : subject)];
//		[_bodyTextView setString:[_selectedRequest body]];
//		[self willChangeValueForKey:@"requestBody"];
//		[self didChangeValueForKey:@"requestBody"];
		[[_bodyHTMLView mainFrame] loadHTMLString:[self requestBodyHTML] baseURL:nil];
		[_takeItButton setEnabled:([_selectedRequest valueForKey:@"xPersonAssignedTo"] == nil)];
		[_viewItButton setEnabled:YES];
	}
	
	[self didChangeValueForKey:@"selectedRequest"];
}

- (IBAction) takeIt: (id) sender
{
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"http://figure53.com/support/admin.php?pg=request&reqid=%d&frominbox=1&rand=%d\"", [_selectedRequest requestID], random()]] autorelease];
	[script executeAndReturnError:nil];
}

- (IBAction) viewRequest: (id) sender
{
	NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"http://figure53.com/support/admin.php?pg=request&reqid=%d\"", [_selectedRequest requestID]]] autorelease];
	[script executeAndReturnError:nil];
}

- (NSString *) requestBodyHTML
{
	NSMutableString *bodyHTML = [NSMutableString string];
	NSString *templateHTML = [NSString stringWithContentsOfURL:
								  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"RequestTemplate" ofType:@"html"]] 
																 encoding:NSUTF8StringEncoding error:nil];

	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateStyle:NSDateFormatterMediumStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	for (int i = 0; i < [_selectedRequest numberOfHistoryItems]; i++)
	{
		HSRequestHistoryItem *item = [_selectedRequest historyItemAtIndex:i];
		[bodyHTML appendFormat:@"<div class=\"item%@%@\"><p class=\"name\">%@%@</p><p class=\"date\">%@</p>%@</div>", 
		 [item body] == nil ? @" logitem" : @" requestitem",
		 (![item public] && [item body] != nil) ? @" private" : @"",
		 [item fullName], 
		 (![item public] && [item body] != nil) ? @" (private)" : @"",
		 [dateFormatter stringFromDate:[item date]],
		 [item body] == nil ? [item log] : [item body]];
	}
	
	return [templateHTML stringByReplacingOccurrencesOfString:@"###REQUESTBODY###" withString:bodyHTML];
}

- (NSAttributedString *) requestBody
{
	NSString *bodyHTML = [self requestBodyHTML];
	NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:[NSFont fontWithName:@"Helvetica" size:12.0], NSFontAttributeName, nil];
	
	return [[[NSAttributedString alloc] initWithHTML:[NSData dataWithBytes:[bodyHTML UTF8String] length:[bodyHTML length]] documentAttributes:&attrs] autorelease];
}

@end
