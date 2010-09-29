//
//  RequestViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HelpSpot/HelpSpot.h>

@class RequestsController;

@interface RequestViewController : NSObject 
{
	RequestsController  *_requestsController;
	HSRequest           *_selectedRequest;
	NSTextField         *_fromTextField;
	NSTextField         *_subjectTextField;
	NSTextView          *_bodyTextView;
	NSButton            *_takeItButton;
	NSButton            *_viewItButton;
}

@property (nonatomic, retain) HSRequest *selectedRequest;
@property (assign) IBOutlet RequestsController *requestsController;
@property (assign) IBOutlet NSTextField *fromTextField;
@property (assign) IBOutlet NSTextField *subjectTextField;
@property (assign) IBOutlet NSTextView *bodyTextView;
@property (assign) IBOutlet NSButton *takeItButton;
@property (assign) IBOutlet NSButton *viewItButton;

- (IBAction) takeIt: (id) sender;
- (IBAction) viewRequest: (id) sender;

@end
