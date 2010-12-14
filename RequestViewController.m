
//
//  RequestViewController.m
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "RequestViewController.h"
#import "RequestController.h"
#import "Request.h"
#import "HelpifierAppDelegate.h"

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

- (Request *) selectedRequest
{
    return _selectedRequest;
}

- (void) setSelectedRequest: (Request *) newRequest
{
    if (newRequest == _selectedRequest)
        return;
    
    [self willChangeValueForKey:@"selectedRequest"];
    
    [_selectedRequest release];
    _selectedRequest = [newRequest retain];
    
    [_fromTextField setStringValue:@""];
    [_subjectTextField setStringValue:(_selectedRequest == nil ? @"" : @"Loading request...")];
    [[_bodyHTMLView mainFrame] loadHTMLString:@"" baseURL:nil];
    [_takeItButton setEnabled:NO];
    [_viewItButton setEnabled:NO];
    
    if (_selectedRequest != nil)
    {
        [_fromTextField setStringValue:[NSString stringWithFormat:@"From: %@ (%@)", [_selectedRequest fullName], [_selectedRequest email]]];
        NSString *subject = [_selectedRequest title];
        [_subjectTextField setStringValue:(subject == nil ? @"(no subject)" : subject)];
        [[_bodyHTMLView mainFrame] loadHTMLString:[self requestBodyHTML] baseURL:nil];
        [_takeItButton setEnabled:([_selectedRequest.properties objectForKey:@"xPersonAssignedTo"] == nil)];
        [_viewItButton setEnabled:YES];
    }
    
    [self didChangeValueForKey:@"selectedRequest"];
}

- (IBAction) takeIt: (id) sender
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"%@/admin.php?pg=request&reqid=%d&frominbox=1&rand=%d\"", AppDelegate.supportURL, [_selectedRequest requestID], random()]] autorelease];
    [script executeAndReturnError:nil];
}

- (IBAction) viewRequest: (id) sender
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"%@/admin.php?pg=request&reqid=%d\"", AppDelegate.supportURL, [_selectedRequest requestID]]] autorelease];
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
    for (HistoryItem *item in _selectedRequest.historyItems)
    {
        [bodyHTML appendFormat:@"<div class=\"item%@%@\"><p class=\"name\">%@%@</p><p class=\"date\">%@</p>%@</div>", 
         [[item body] isEqual:@""] ? @" logitem" : @" requestitem",
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
