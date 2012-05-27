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
@property (strong) IBOutlet NSToolbarItem *connectionToolbarItem;
@property (strong) IBOutlet NSToolbarItem *notificationToolbarItem;
@property (strong) IBOutlet NSView *connectionPreferencesView;
@property (strong) IBOutlet NSView *notificationPreferencesView;

// These properties are cached while the user edits the connection options, but only applied when they hit "Apply Changes" or close the window.
@property (nonatomic, copy) NSString *tempBaseURL;
@property (copy) NSString *tempAPIURL;
@property (copy) NSString *tempUsername;
@property (copy) NSString *tempPassword;

- (void)showPreferences;
- (IBAction)showConnectionPreferences:(id)sender;
- (IBAction)showNotificationPreferences:(id)sender;
- (IBAction)setNotificationSound:(id)sender;
- (IBAction)setNotificationSoundFromDefaultOptions:(id)sender;
- (IBAction)acceptLoginInformation:(id)sender;

@end
