//
//  HelpifierAppDelegate.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObjectDelegateProtocol.h"

#define AppDelegate ((HelpifierAppDelegate *)[NSApp delegate])

@class RequestController;

@interface HelpifierAppDelegate : NSObject <NSApplicationDelegate> 
{
    NSWindow            *_window;
    RequestController   *_requestController;
    NSWindow            *_prefsWindow;
    
    NSMutableDictionary *_notifiedUnreadRequests;
    NSInteger            _attentionRequest;
}

@property (assign) IBOutlet RequestController *requestController;
@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSWindow *prefsWindow;
@property (retain) NSString *username;
@property (retain) NSString *password;
@property (retain) NSString *apiURL;
@property (retain) NSString *supportURL;

- (IBAction) help: (id) sender;
- (IBAction) showPreferences: (id) sender;
- (IBAction) chooseSystemSound: (id) sender;

- (void) setUnreadRequests: (NSDictionary *) newRequests notify: (BOOL) shouldNotify;

@end
