//
//  EditingRequestControlsViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//
//	Copyright (c) 2011 Figure 53 LLC, http://figure53.com
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

#import <Cocoa/Cocoa.h>
#import "DataObjectDelegateProtocol.h"


@class RequestViewController;
@class AttachmentsArrayController;
@class Request;


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
@property (readonly) BOOL nibLoaded;

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

- (void) setOptionsFromExistingRequest: (Request *) request;
- (IBAction) changeOptions: (id) sender;
- (void) updateOptions;
- (void) resetOptions;

@end
