//
//  InboxRequestControlsViewController.h
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RequestViewController;


@interface InboxRequestControlsViewController : NSObject 
{
    NSView                  *_controlsView;
    RequestViewController   *_viewController;
	NSButton                *_takeItButton;
	NSButton                *_viewItButton;
}

@property (assign) RequestViewController *viewController;
@property (assign) IBOutlet NSView *controlsView;
@property (assign) IBOutlet NSButton *takeItButton;
@property (assign) IBOutlet NSButton *viewItButton;

- (IBAction) takeItInHelpifier: (id) sender;
- (IBAction) takeItOnWebSite: (id) sender;
- (IBAction) viewRequest: (id) sender;

@end
