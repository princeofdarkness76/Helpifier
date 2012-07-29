//
//  PreferencesController.h
//  Helpifier
//
//  Created by Sean Dougall on 4/18/12.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
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
