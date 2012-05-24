//
//  HelpifierAppDelegate.h
//  Helpifier
//
//  Created by Sean Dougall on 11/18/11.
//  Copyright 2012 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HelpSpotController;
@class RequestCellView;
@class RequestController;
@class FHSStatusTypeCollection;

@interface HelpifierAppDelegate : NSObject <NSApplicationDelegate, NSOutlineViewDataSource, NSOutlineViewDelegate, NSSplitViewDelegate>
{
    HelpSpotController *_helpSpot;
}

@property (strong) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSSplitView *splitView;
@property (weak) IBOutlet NSOutlineView *requestList;
@property (weak) IBOutlet NSView *containerView;
@property (weak) IBOutlet NSView *requestView;
@property (strong) IBOutlet NSView *noRequestView;
@property (strong) IBOutlet NSView *requestNotFoundView;
@property (strong) IBOutlet NSTextField *noRequestLabel;
@property (weak) IBOutlet NSView *requestListFooterView;
@property (weak) IBOutlet NSButton *refreshButton;
@property (weak) IBOutlet NSProgressIndicator *loadingIndicator;
@property (weak) IBOutlet NSImageView *warningImageView;
@property (weak) IBOutlet NSButton *otherRequestButton;
@property (weak) IBOutlet NSPopover *otherRequestPopover;
@property (readonly) FHSStatusTypeCollection *statusTypes;

- (IBAction)showPreferences:(id)sender;
- (IBAction)refreshNow:(id)sender;
- (IBAction)showHelp:(id)sender;
- (IBAction)selectOtherRequest:(id)sender;
- (void)goToOtherRequest:(NSInteger)requestNumber;
- (void)dismissOtherRequest;

@end
