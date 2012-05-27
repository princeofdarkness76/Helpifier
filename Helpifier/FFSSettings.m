//
//  FFSSettings.m
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FFSSettings.h"
#import <Security/Security.h>
#import "EMKeychain/EMKeychainItem.h"

static FFSSettings *_sharedSettings = nil;

@interface FFSSettings ()

@property (nonatomic, strong) EMGenericKeychainItem *helpSpotPasswordItem;

@end

#pragma mark -

@implementation FFSSettings

@synthesize helpSpotPasswordItem = _helpSpotPasswordItem;

- (EMGenericKeychainItem *)helpSpotPasswordItem
{
    if ( !_helpSpotPasswordItem )
        _helpSpotPasswordItem = [EMGenericKeychainItem genericKeychainItemForService:@"Helpifier" withUsername:[self helpSpotUsername]];
    
    return _helpSpotPasswordItem;
}

- (NSString *)helpSpotUsername
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSUsername"];
}

- (NSString *)helpSpotPassword
{
    EMKeychainItem *passwordItem = self.helpSpotPasswordItem;
    if ( passwordItem )
    {
        return passwordItem.password;
    }
    
    // We used to store the password in the user defaults, so see if it's there. If it is, move it to the keychain.
    NSString *passwordFromDefaults = [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSPassword"];
    if ( [passwordFromDefaults length] > 0 )
    {
        [self setHelpSpotPassword:passwordFromDefaults];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"FHSPassword"];
        return passwordFromDefaults;
    }
    
    return nil;
}

- (void)setHelpSpotPassword:(NSString *)helpSpotPassword
{
    if ( self.helpSpotPasswordItem )
    {
        self.helpSpotPasswordItem.password = helpSpotPassword;
    }
    else
    {
        self.helpSpotPasswordItem = [EMGenericKeychainItem addGenericKeychainItemForService:@"Helpifier" withUsername:[self helpSpotUsername] password:helpSpotPassword];
    }
}

- (NSURL *)helpSpotBaseURL
{
    return [[NSUserDefaults standardUserDefaults] URLForKey:@"FHSBaseURL"];
}

- (NSURL *)helpSpotBaseAPIURL
{
    if ( [[NSUserDefaults standardUserDefaults] URLForKey:@"FHSBaseAPIURL"] )
        return [[NSUserDefaults standardUserDefaults] URLForKey:@"FHSBaseAPIURL"];
    
    if ( [self helpSpotBaseURL] == nil )
        return nil;
    
    return [[self helpSpotBaseURL] URLByAppendingPathComponent:@"api" isDirectory:YES];
}

- (float)timeoutInterval
{
    return 10.0;
}

- (id)init
{
    if (_sharedSettings)
    {
        self = nil;
        return _sharedSettings;
    }
    
    self = [super init];
    if (self)
    {
        id baseURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSBaseURL"];
        if ( [baseURL isKindOfClass:[NSString class]] )
            [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:baseURL] forKey:@"FHSBaseURL"];
        id baseAPIURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSBaseAPIURL"];
        if ( [baseURL isKindOfClass:[NSString class]] )
            [[NSUserDefaults standardUserDefaults] setURL:[NSURL URLWithString:baseAPIURL] forKey:@"FHSBaseAPIURL"];
        _sharedSettings = self;
    }
    return self;
}

+ (FFSSettings *)sharedSettings
{
    if (_sharedSettings)
        return _sharedSettings;
    
    return [[FFSSettings alloc] init];
}

@end
