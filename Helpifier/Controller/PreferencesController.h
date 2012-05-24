//
//  PreferencesController.h
//  Helpifier
//
//  Created by Sean Dougall on 4/18/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PreferencesController : NSObject <NSWindowDelegate>

@property (strong) IBOutlet NSWindow *preferencesWindow;
@property (strong) IBOutlet NSTextField *baseURLField;
@property (strong) IBOutlet NSTextField *baseAPIURLField;
@property (strong) IBOutlet NSTextField *usernameField;
@property (strong) IBOutlet NSTextField *passwordField;
@property (strong) IBOutlet NSTextField *notificationSoundField;

- (void)showPreferences;
- (IBAction)setBaseURL:(id)sender;
- (IBAction)setAPIURL:(id)sender;
- (IBAction)setUsername:(id)sender;
- (IBAction)setPassword:(id)sender;
- (IBAction)setNotificationSound:(id)sender;
- (IBAction)setNotificationSoundFromDefaultOptions:(id)sender;

@end
