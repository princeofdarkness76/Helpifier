//
//  EditingRequestControlsViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObjectDelegateProtocol.h"


@class RequestViewController;
@class AttachmentsArrayController;


@interface EditingRequestControlsViewController : NSObject <DataObjectDelegate>
{
    RequestViewController       *_viewController;
    NSView                      *_controlsView;
    AttachmentsArrayController  *_attachments;
    
    NSTextView                  *_noteTextView;
    NSTableView                 *_attachmentsTable;
    NSTokenField                *_ccField;
    NSTokenField                *_bccField;
    NSPopUpButton               *_optionsPullDown;
    NSTextView                  *_optionsPreviewTextView;
    NSPopUpButton               *_closeAsPullDown;
    
    // Options
    NSString                    *_category;
    NSMutableArray              *_tags;
    NSMutableArray              *_notify;
    BOOL                         _privateNote;
}

@property (assign) IBOutlet NSView *controlsView;
@property (assign) IBOutlet AttachmentsArrayController *attachments;
@property (assign) RequestViewController *viewController;

@property (assign) IBOutlet NSTextView *noteTextView;
@property (assign) IBOutlet NSTableView *attachmentsTable;
@property (assign) IBOutlet NSTokenField *ccField;
@property (assign) IBOutlet NSTokenField *bccField;
@property (assign) IBOutlet NSPopUpButton *optionsPullDown;
@property (assign) IBOutlet NSTextView *optionsPreviewTextView;
@property (assign) IBOutlet NSPopUpButton *closeAsPullDown;

- (void) setupTableView;

- (IBAction) update: (id) sender;
- (IBAction) updateAndClose: (id) sender;
- (IBAction) viewOnWebSite: (id) sender;

- (IBAction) changeOptions: (id) sender;
- (void) updateOptions;
- (void) resetOptions;

@end
