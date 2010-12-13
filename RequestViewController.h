//
//  RequestViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 9/28/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@class RequestController;
@class Request;

@interface RequestViewController : NSObject 
{
	RequestController   *_requestsController;
	Request             *_selectedRequest;
	NSTextField         *_fromTextField;
	NSTextField         *_subjectTextField;
//	NSTextView          *_bodyTextView;
	WebView             *_bodyHTMLView;
	NSButton            *_takeItButton;
	NSButton            *_viewItButton;
}

@property (nonatomic, retain) Request *selectedRequest;
@property (assign) IBOutlet RequestController *requestsController;
@property (assign) IBOutlet NSTextField *fromTextField;
@property (assign) IBOutlet NSTextField *subjectTextField;
//@property (assign) IBOutlet NSTextView *bodyTextView;
@property (assign) IBOutlet WebView *bodyHTMLView;
@property (assign) IBOutlet NSButton *takeItButton;
@property (assign) IBOutlet NSButton *viewItButton;
@property (readonly) NSString *requestBodyHTML;
@property (readonly) NSAttributedString *requestBody;

- (IBAction) takeIt: (id) sender;
- (IBAction) viewRequest: (id) sender;

@end
