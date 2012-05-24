//
//  PreferencesController.m
//  Helpifier
//
//  Created by Sean Dougall on 4/18/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "PreferencesController.h"
#import "HelpifierAppDelegate.h"
#import "FFSSettings.h"

@interface PreferencesController ()

- (void)_synchronize;
- (void)_setValue:(id)value onTextField:(NSTextField *)textField;

@end

#pragma mark -

@implementation PreferencesController

@synthesize preferencesWindow = _preferencesWindow;

@synthesize baseURLField = _baseURLField;

@synthesize baseAPIURLField = _baseAPIURLField;

@synthesize usernameField = _usernameField;

@synthesize passwordField = _passwordField;

@synthesize notificationSoundField = _notificationSoundField;

- (void)showPreferences
{
    if ( _preferencesWindow == nil )
    {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    }
    
    [_preferencesWindow makeKeyAndOrderFront:self];
}

- (IBAction)setBaseURL:(id)sender
{
    NSString *newURL = [sender stringValue];
    if ( [newURL rangeOfString:@"://"].location == NSNotFound )
        newURL = [NSString stringWithFormat:@"http://%@", newURL];
    if ( ![[newURL substringFromIndex:newURL.length - 1] isEqualToString:@"/"] )
        newURL = [NSString stringWithFormat:@"%@/", newURL];
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:newURL] forKey:@"FHSBaseURL"];
    [self _synchronize];
}

- (IBAction)setAPIURL:(id)sender
{
    NSString *newURL = [sender stringValue];
    if ( [newURL length] == 0 )
        return;
    if ( [newURL rangeOfString:@"://"].location == NSNotFound )
        newURL = [NSString stringWithFormat:@"http://%@", newURL];
    if ( ![[newURL substringFromIndex:newURL.length - 1] isEqualToString:@"/"] )
        newURL = [NSString stringWithFormat:@"%@/", newURL];
    [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:newURL] forKey:@"FHSBaseAPIURL"];
    [self _synchronize];
}

- (IBAction)setUsername:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[sender stringValue] forKey:@"FHSUsername"];
    [self _synchronize];
}

- (IBAction)setPassword:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[sender stringValue] forKey:@"FHSPassword"];
    [self _synchronize];
}

- (IBAction)setNotificationSound:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[sender stringValue] forKey:@"notificationSound"];
    [self _synchronize];
}

- (IBAction)setNotificationSoundFromDefaultOptions:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setValue:[sender title] forKey:@"notificationSound"];
    [_notificationSoundField setStringValue:[sender title]];
    [self _synchronize];
}

#pragma mark -

- (void)_synchronize
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [(HelpifierAppDelegate *)[NSApp delegate] refreshNow:self];
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    [self _setValue:[[FFSSettings sharedSettings] helpSpotBaseURL] onTextField:_baseURLField];
    [self _setValue:[[FFSSettings sharedSettings] helpSpotBaseAPIURL] onTextField:_baseAPIURLField];
    [self _setValue:[[FFSSettings sharedSettings] helpSpotUsername] onTextField:_usernameField];
    [self _setValue:[[FFSSettings sharedSettings] helpSpotPassword] onTextField:_passwordField];
}

- (void)_setValue:(id)value onTextField:(NSTextField *)textField
{
    textField.objectValue = value ? value : @"";
}

@end
