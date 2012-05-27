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
- (void)_showPreferencesWithView:(NSView *)newView;
- (void)_addView:(NSView *)newView;
- (NSString *)_fixedURLFromString:(NSString *)string;

@end

#pragma mark -

@implementation PreferencesController

@synthesize preferencesWindow = _preferencesWindow;
@synthesize baseURLField = _baseURLField;
@synthesize baseAPIURLField = _baseAPIURLField;
@synthesize usernameField = _usernameField;
@synthesize passwordField = _passwordField;
@synthesize notificationSoundField = _notificationSoundField;
@synthesize connectionToolbarItem = _connectionToolbarItem;
@synthesize notificationToolbarItem = _notificationToolbarItem;
@synthesize connectionPreferencesView = _connectionPreferencesView;
@synthesize notificationPreferencesView = _notificationPreferencesView;

@synthesize tempBaseURL = _tempBaseURL;
@synthesize tempAPIURL = _tempAPIURL;
@synthesize tempUsername = _tempUsername;
@synthesize tempPassword = _tempPassword;

- (void)setTempBaseURL:(NSString *)tempBaseURL
{
    _tempBaseURL = [tempBaseURL copy];
    NSString *newURL = [self _fixedURLFromString:tempBaseURL];
    [[_baseAPIURLField cell] setPlaceholderString:[newURL stringByAppendingString:@"api/"]];
}

- (void)showPreferences
{
    if ( _preferencesWindow == nil )
    {
        [NSBundle loadNibNamed:@"Preferences" owner:self];
    }
    
    NSString *lastSelectedTab = [[NSUserDefaults standardUserDefaults] valueForKey:@"preferencesTab"];
    if ( [lastSelectedTab isEqualToString:@"Notifications"] )
    {
        [self showNotificationPreferences:self];
    }
    else
    {
        [self showConnectionPreferences:self];
    }
}

- (IBAction)showConnectionPreferences:(id)sender
{
    [_notificationToolbarItem.toolbar setSelectedItemIdentifier:@"Connection"];
    [[NSUserDefaults standardUserDefaults] setValue:@"Connection" forKey:@"preferencesTab"];
    [self _showPreferencesWithView:self.connectionPreferencesView];
}

- (IBAction)showNotificationPreferences:(id)sender
{
    [_notificationToolbarItem.toolbar setSelectedItemIdentifier:@"Notifications"];
    [[NSUserDefaults standardUserDefaults] setValue:@"Notifications" forKey:@"preferencesTab"];
    [self _showPreferencesWithView:self.notificationPreferencesView];
}

- (void)_showPreferencesWithView:(NSView *)newView
{
    [_preferencesWindow makeKeyAndOrderFront:self];
    
    [[NSAnimationContext currentContext] setDuration:0.05];
    
    NSView *subview = [[self.preferencesWindow.contentView subviews] lastObject];
    if ( subview != nil && subview != newView )
    {
        [[NSAnimationContext currentContext] setCompletionHandler:^{
            [subview removeFromSuperview];
            [self _addView:newView];
        }];
        [subview.animator setAlphaValue:0.0];
    }
    else if ( subview == nil )
    {
        [self _addView:newView];
    }
}

- (void)_addView:(NSView *)newView
{
    [newView setFrameOrigin:NSZeroPoint];
    [newView setAlphaValue:0.0];
    
    NSRect oldFrame = self.preferencesWindow.frame;
    NSRect newFrame = oldFrame;
    newFrame.size.width += newView.frame.size.width - [self.preferencesWindow.contentView frame].size.width;
    newFrame.size.height += newView.frame.size.height - [self.preferencesWindow.contentView frame].size.height;
    newFrame.origin.x -= ( newFrame.size.width - oldFrame.size.width ) / 2.0;
    newFrame.origin.y -= ( newFrame.size.height - oldFrame.size.height );
    
    [self.preferencesWindow setFrame:newFrame display:YES animate:YES];

    [[NSAnimationContext currentContext] setDuration:0.05];
    [self.preferencesWindow.contentView addSubview:newView];
    [newView.animator setAlphaValue:1.0];
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

- (IBAction)acceptLoginInformation:(id)sender
{
    [self _synchronize];
}

#pragma mark -

- (void)_synchronize
{
    if ( !_tempBaseURL )
        return;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setURL:[NSURL URLWithString:[self _fixedURLFromString:self.tempBaseURL]] forKey:@"FHSBaseURL"];
    if ( self.tempAPIURL.length > 0 )
    {
        [defaults setURL:[NSURL URLWithString:[self _fixedURLFromString:self.tempAPIURL]] forKey:@"FHSBaseAPIURL"];
    }
    else
    {
        [defaults removeObjectForKey:@"FHSBaseAPIURL"];
    }
    [defaults setObject:( self.tempUsername ? self.tempUsername : @"" ) forKey:@"FHSUsername"];
    [[FFSSettings sharedSettings] setHelpSpotPassword:self.tempPassword];
    [defaults synchronize];
    
    [(HelpifierAppDelegate *)[NSApp delegate] refreshNow:self];
}

- (NSString *)_fixedURLFromString:(NSString *)string
{
    if ( string.length == 0 )
        return @"http://example.com/help/";
    if ( [string rangeOfString:@"://"].location == NSNotFound )
        string = [NSString stringWithFormat:@"http://%@", string];
    if ( ![[string substringFromIndex:string.length - 1] isEqualToString:@"/"] )
        string = [string stringByAppendingString:@"/"];
    return string;
}

#pragma mark - NSWindowDelegate

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    self.tempBaseURL = [[[FFSSettings sharedSettings] helpSpotBaseURL] description];
    self.tempAPIURL = [[[FFSSettings sharedSettings] helpSpotBaseAPIURL] description];
    self.tempUsername = [[FFSSettings sharedSettings] helpSpotUsername];
    self.tempPassword = [[FFSSettings sharedSettings] helpSpotPassword];
}

- (void)windowWillClose:(NSNotification *)notification
{
    [self _synchronize];
}

- (void)_setValue:(id)value onTextField:(NSTextField *)textField
{
    textField.objectValue = value ? value : @"";
}

@end
