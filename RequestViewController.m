
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
#import "InboxRequestControlsViewController.h"
#import "EditingRequestControlsViewController.h"

@interface RequestViewController (Private)

- (void) showInboxControls;
- (void) showEditingControls;

@end


@implementation RequestViewController (Private)

- (void) showInboxControls
{
    [NSBundle loadNibNamed:@"InboxRequestControls" owner:_inboxControls];
    
    for (NSView *subview in [_controlsContainerView subviews])
        [subview removeFromSuperview];
    
    [_inboxControls.controlsView setFrameSize:[_controlsContainerView frame].size];
    
    [_controlsContainerView addSubview:_inboxControls.controlsView];
    
    [_splitView setPosition:[_splitView frame].size.height - 80 ofDividerAtIndex:0];
    [_splitView adjustSubviews];
}

- (void) showEditingControls
{
    [NSBundle loadNibNamed:@"EditingRequestControls" owner:_editingControls];
    
    for (NSView *subview in [_controlsContainerView subviews])
        [subview removeFromSuperview];
    
    [_splitView setPosition:[_splitView frame].size.height - 250 ofDividerAtIndex:0];
    [_splitView adjustSubviews];
    
    [_editingControls.controlsView setFrameSize:[_controlsContainerView frame].size];
    
    [_controlsContainerView addSubview:_editingControls.controlsView];
    
    [_editingControls updateOptions];
    [_editingControls setupTableView];
}

@end


@implementation RequestViewController

- (void) awakeFromNib
{
    _selectedRequest = nil;
    _inboxControls = [[InboxRequestControlsViewController alloc] init];
    _editingControls = [[EditingRequestControlsViewController alloc] init];
    _inboxControls.viewController = self;
    _editingControls.viewController = self;
    
    [self showEditingControls];
}

- (void) dealloc
{
    [_inboxControls release];
    _inboxControls = nil;
    
    [_editingControls release];
    _editingControls = nil;
    
    self.selectedRequest = nil;
    [super dealloc];
}

@synthesize requestsController = _requestsController;
@synthesize fromTextField = _fromTextField;
@synthesize subjectTextField = _subjectTextField;
@synthesize otherRequestTextField = _otherRequestTextField;
//@synthesize bodyTextView = _bodyTextView;
@synthesize bodyHTMLView = _bodyHTMLView;
@synthesize controlsContainerView = _controlsContainerView;
@synthesize inboxControls = _inboxControls;
@synthesize editingControls = _editingControls;
@synthesize splitView = _splitView;

- (Request *) selectedRequest
{
    return _selectedRequest;
}

- (void) setSelectedRequest: (Request *) newRequest
{
    if ([newRequest requestID] == [_selectedRequest requestID])
        return;
    
    [self willChangeValueForKey:@"selectedRequest"];
    
    [_selectedRequest release];
    _selectedRequest = [newRequest retain];
    
    [_fromTextField setStringValue:@""];
    [_subjectTextField setStringValue:(_selectedRequest == nil ? @"" : @"Loading request...")];
    [[_bodyHTMLView mainFrame] loadHTMLString:@"" baseURL:nil];
    [_inboxControls.takeItButton setEnabled:NO];
    [_inboxControls.viewItButton setEnabled:NO];
    
    if (_selectedRequest == nil)
    {
        [self showInboxControls];
    }
    else
    {
        [_fromTextField setStringValue:[NSString stringWithFormat:@"From: %@ (%@)", [_selectedRequest fullName], [_selectedRequest email]]];
        NSString *subject = [_selectedRequest title];
        [_subjectTextField setStringValue:(subject == nil ? @"(no subject)" : subject)];
        [[_bodyHTMLView mainFrame] loadHTMLString:[self requestBodyHTML] baseURL:nil];
        NSString *personAssigned = [_selectedRequest.properties objectForKey:@"xPersonAssignedTo"];
        if (personAssigned == nil || [personAssigned isEqual:@""] || [personAssigned isEqual:@"INBOX"])
        {
            [self showInboxControls];
            [_inboxControls.takeItButton setEnabled:YES];
            [_inboxControls.viewItButton setEnabled:YES];
        }
        else
        {
            NSLog(@"person: %@", _selectedRequest.properties);
            [self showEditingControls];
        }
    }
    
    [self didChangeValueForKey:@"selectedRequest"];
}

#pragma mark -
#pragma mark taking requests

- (void) startTakingIt
{
    // Before assigning, make sure this request is still in the inbox
    _selectedRequest.delegate = self;
    [_selectedRequest beginFetch];
}

- (void) dataObjectDidFinishFetch: (DataObject *) obj
{
    if ([obj isKindOfClass:[Request class]])    // heard back from request as to whether it's still taken
    {
        Request *req = (Request *)obj;
        NSString *person = [req.properties objectForKey:@"xPersonAssignedTo"];
        if (person == nil || [person isEqual:@"INBOX"] || [person isEqual:@""])
        {
            RequestUpdate *update = [[RequestUpdate alloc] initToTakeRequestID:[NSString stringWithFormat:@"%d", _selectedRequest.requestID] withDelegate:self];
            [update autorelease];
        }
        else
        {
            NSRunAlertPanel(@"Cannot take this request.", @"%@ beat you to it.", @"OK", nil, nil, [req.properties objectForKey:@"xPersonAssignedTo"]);
        }
        
        // We're done with the request here, so set its delegate back to the original controller.
        req.delegate = _requestsController;
    }
    else if ([obj isKindOfClass:[RequestUpdate class]])   // Finished assigning the request to the user
    {
        [self showEditingControls];
        [_requestsController refreshRequests:self];
    }
}

- (void) dataObjectDidFailFetchWithError: (NSString *) err
{
    _selectedRequest.delegate = _requestsController;    // In the event of a failure, we may have changed the request's delegate, so change it back just in case
    NSRunAlertPanel(@"Unable to take request.", @"An error occurred while attempting to take this request: %@", @"OK", nil, nil, err);
}


#pragma mark -
#pragma mark other actions

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

- (IBAction) selectOtherRequestTextField: (id) sender
{
    [_otherRequestTextField becomeFirstResponder];
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

#pragma mark -
#pragma mark Split view delegate

- (CGFloat) splitView: (NSSplitView *) splitView
constrainMaxCoordinate: (CGFloat) proposedMax
          ofSubviewAt: (NSInteger) dividerIndex
{
    if (_selectedRequest == nil)
        return [splitView frame].size.height - 50;
    
    NSString *personAssigned = [_selectedRequest.properties objectForKey:@"xPersonAssignedTo"];
    if (personAssigned == nil || [personAssigned isEqual:@""] || [personAssigned isEqual:@"INBOX"])
        return [splitView frame].size.height - 50;
    
    return [splitView frame].size.height - 200;
}

- (CGFloat) splitView: (NSSplitView *) splitView
constrainMinCoordinate: (CGFloat) proposedMin
          ofSubviewAt: (NSInteger) dividerIndex
{
    if (_selectedRequest == nil)
        return 50;
    
    NSString *personAssigned = [_selectedRequest.properties objectForKey:@"xPersonAssignedTo"];
    if (personAssigned == nil || [personAssigned isEqual:@""] || [personAssigned isEqual:@"INBOX"])
        return 50;
    
    return 10;
}

- (BOOL) splitView: (NSSplitView *) splitView 
canCollapseSubview: (NSView *) subview
{
    return YES;
}


@end
