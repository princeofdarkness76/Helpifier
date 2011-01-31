//
//  EditingRequestControlsViewController.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import "EditingRequestControlsViewController.h"
#import "RequestUpdate.h"
#import "Request.h"
#import "RequestViewController.h"
#import "DataHeaders.h"
#import "HelpifierAppDelegate.h"


@implementation EditingRequestControlsViewController

- (id) init
{
    if (self = [super init]) 
    {
        [self resetOptions];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOptions) name:@"StaffDidChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOptions) name:@"CategoriesDidChangeNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOptions) name:@"StatusesDidChangeNotification" object:nil];
        [self updateOptions];
    }
    return self;
}


@synthesize controlsView = _controlsView;
@synthesize attachments = _attachments;
@synthesize attachmentsTable = _attachmentsTable;
@synthesize viewController = _viewController;
@synthesize noteTextView = _noteTextView;
@synthesize ccField = _ccField;
@synthesize bccField = _bccField;
@synthesize optionsPullDown = _optionsPullDown;
@synthesize optionsPreviewTextView = _optionsPreviewTextView;
@synthesize closeAsPullDown = _closeAsPullDown;

- (void) setupTableView
{
    [_attachmentsTable registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
}

- (IBAction) update: (id) sender
{
    RequestUpdate *update = [[RequestUpdate alloc] initWithRequestID:[[_viewController.selectedRequest.properties objectForKey:@"xRequest"] description]
                                                                note:[_noteTextView string]
                                                         privateNote:_privateNote
                                                         attachments:[_attachments content]
                                                                  cc:[_ccField stringValue]
                                                                 bcc:[_bccField stringValue]
                                                              status:@"Active"
                                                                open:YES
                                                            delegate:self];
    [update autorelease];
}

- (IBAction) updateAndClose: (id) sender
{
    RequestUpdate *update = [[RequestUpdate alloc] initWithRequestID:[[_viewController.selectedRequest.properties objectForKey:@"xRequest"] description]
                                                                note:[_noteTextView string]
                                                         privateNote:_privateNote
                                                         attachments:[_attachments content]
                                                                  cc:[_ccField stringValue]
                                                                 bcc:[_bccField stringValue]
                                                              status:[sender title]
                                                                open:NO
                                                            delegate:self];
    [update autorelease];
}

- (IBAction) viewOnWebSite: (id) sender
{
    NSAppleScript *script = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:@"open location \"%@/admin.php?pg=request&reqid=%d\"", AppDelegate.supportURL, [_viewController.selectedRequest requestID]]] autorelease];
    [script executeAndReturnError:nil];
}

#pragma mark -
#pragma mark Options popup management

- (IBAction) changeOptions: (id) sender
{
    NSString *title = [sender title];
    
    if ([title isEqualToString:@"Private Note"])
    {
        _privateNote = YES;
    }
    else if ([title isEqualToString:@"Public Note"])
    {
        _privateNote = NO;
    }
    else if ([[[sender menu] title] isEqualToString:@"Tags"])
    {
        if ([sender state] == NSOffState)   // state is previous to action
            [_tags addObject:title];
        else
            [_tags removeObject:title];
    }
    else if ([[[sender menu] title] isEqualToString:@"Category"])
    {
        NSString *oldCategory = _category;
        _category = [title retain];
        [oldCategory release];
    }
    else if ([[[sender menu] title] isEqualToString:@"Notify"])
    {
        if ([sender state] == NSOffState)
            [_notify addObject:title];
        else
            [_notify removeObject:title];
    }
    
    [self updateOptions];
}

- (void) updateOptions
{
    NSMutableString *preview = [NSMutableString string];
    SEL action = @selector(changeOptions:);
    
    // Public/Private note setting
    if (_privateNote)
    {
        [[[_optionsPullDown menu] itemWithTitle:@"Private Note"] setState:NSOnState];
        [[[_optionsPullDown menu] itemWithTitle:@"Public Note"] setState:NSOffState];
        [preview appendString:@"--- private note ---\n"];
    }
    else
    {
        [[[_optionsPullDown menu] itemWithTitle:@"Private Note"] setState:NSOffState];
        [[[_optionsPullDown menu] itemWithTitle:@"Public Note"] setState:NSOnState];
    }
    
    
    // Category
    [[[[_optionsPullDown menu] itemWithTitle:@"Category"] submenu] removeAllItems];
    for (NSDictionary *category in [[CategoryCollection collection] categories])
    {
        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        [item setTitle:[category objectForKey:@"sCategory"]];
        [item setTarget:self];
        [item setAction:action];
        [[[[_optionsPullDown menu] itemWithTitle:@"Category"] submenu] addItem:item];
    }
    
    for (NSMenuItem *item in [[[[_optionsPullDown menu] itemWithTitle:@"Category"] submenu] itemArray])
        [item setState:NSOffState];
    
    if (_category != nil)
        [[[[[_optionsPullDown menu] itemWithTitle:@"Category"] submenu] itemWithTitle:_category] setState:NSOnState];
    [preview appendFormat:@"Category: %@\n", _category == nil ? @"(none)" : _category];

    
    // Tags
    [[[[_optionsPullDown menu] itemWithTitle:@"Tags"] submenu] removeAllItems];
    for (NSDictionary *tag in [[[CategoryCollection collection] categoryWithTitle:_category] objectForKey:@"reportingTags"])
    {
        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        [item setTitle:[tag objectForKey:@"sReportingTag"]];
        [item setTarget:self];
        [item setAction:action];
        [[[[_optionsPullDown menu] itemWithTitle:@"Tags"] submenu] addItem:item];
    }
    
    for (NSMenuItem *item in [[[[_optionsPullDown menu] itemWithTitle:@"Tags"] submenu] itemArray])
        [item setState:NSOffState];
    
    NSMutableArray *tagsToRemove = [NSMutableArray array];
    for (NSString *tag in _tags)
    {
        NSMenuItem *tagItem = [[[[_optionsPullDown menu] itemWithTitle:@"Tags"] submenu] itemWithTitle:tag];
        if (tagItem == nil)
            [tagsToRemove addObject:tag];
        else
            [tagItem setState:NSOnState];
    }
    [_tags removeObjectsInArray:tagsToRemove];
    [preview appendFormat:@"Tags: %@\n", [_tags count] > 0 ? [_tags componentsJoinedByString:@", "] : @"(none)"];
    
    
    // Notifications
    [[[[_optionsPullDown menu] itemWithTitle:@"Notify"] submenu] removeAllItems];
    for (NSDictionary *person in [[Staff staff] people])
    {
        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        [item setTitle:[person objectForKey:@"fullname"]];
        [item setTarget:self];
        [item setAction:action];
        [[[[_optionsPullDown menu] itemWithTitle:@"Notify"] submenu] addItem:item];
    }
    
    for (NSString *person in _notify)
    {
        [[[[[_optionsPullDown menu] itemWithTitle:@"Notify"] submenu] itemWithTitle:person] setState:NSOnState];
    }
    
    if ([_notify count] > 0)
        [preview appendFormat:@"Notify: %@", [_notify componentsJoinedByString:@", "]];
    
    
    // Close As
    [[_closeAsPullDown menu] removeAllItems];
    NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
    [item setTitle:@"Close As"];
    [[_closeAsPullDown menu] addItem:item];
    for (NSDictionary *status in [[StatusCollection collection] statuses])
    {
        if ([[status objectForKey:@"sStatus"] isEqual:@"Active"]) continue;
        NSMenuItem *item = [[[NSMenuItem alloc] init] autorelease];
        [item setTitle:[status objectForKey:@"sStatus"]];
        [item setTarget:self];
        [item setAction:@selector(updateAndClose:)];
        [[_closeAsPullDown menu] addItem:item];
    }
    
    
    [_optionsPreviewTextView setString:preview];
}

- (void) resetOptions
{
    _category = nil;
    _tags = [NSMutableArray new];
    _notify = [NSMutableArray new];
    _privateNote = NO;
}    

#pragma mark -
#pragma mark Split view delegate

- (CGFloat) splitView: (NSSplitView *) splitView 
constrainMinCoordinate: (CGFloat) proposedMin
          ofSubviewAt: (NSInteger) dividerIndex
{
    return proposedMin;
}

- (BOOL) splitView: (NSSplitView *) splitView
canCollapseSubview: (NSView *) subview
{
    return YES;
}

#pragma mark -
#pragma mark RequestUpdate delegate

- (void) dataObjectDidFinishFetch: (DataObject *) obj
{
    [_viewController setSelectedRequest:nil];
    [_viewController.requestsController refreshRequests:self];
}

- (void) dataObjectDidFailFetchWithError: (NSString *) err
{
    NSRunAlertPanel(@"Unable to update request.", @"An error occurred while attempting to update this request: %@", @"OK", nil, nil, err);
}

@end
