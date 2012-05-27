//
//  FFSSettings.m
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FFSSettings.h"
#import <Security/Security.h>

static FFSSettings *_sharedSettings = nil;

@interface FFSSettings ()

@property (copy) NSString *cachedHelpSpotPassword;
- (NSString *)_helpSpotPasswordFromKeychain;
- (SecKeychainItemRef)_helpSpotPasswordKeychainItem;

@end

#pragma mark -

@implementation FFSSettings

@synthesize cachedHelpSpotPassword = _cachedHelpSpotPassword;

- (NSString *)helpSpotUsername
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSUsername"];
}

- (NSString *)helpSpotPassword
{
    if ( _cachedHelpSpotPassword )
        return _cachedHelpSpotPassword;
    
    NSString *passwordFromKeychain = [self _helpSpotPasswordFromKeychain];
    if ( passwordFromKeychain )
    {
        self.cachedHelpSpotPassword = passwordFromKeychain;
        return passwordFromKeychain;
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
    self.cachedHelpSpotPassword = helpSpotPassword;
    NSString *serviceName = @"Helpifier";
    NSString *accountName = [self helpSpotUsername];
    if ( [accountName length] == 0 ) return;
    
    OSStatus err = SecKeychainAddGenericPassword( NULL, [serviceName length], [serviceName UTF8String], [accountName length], [accountName UTF8String], [helpSpotPassword length], [helpSpotPassword UTF8String], NULL );
    if ( err )
    {
        SecKeychainItemRef item = [self _helpSpotPasswordKeychainItem];
        if ( item )
        {
            NSLog( @"item already exists." );  // FIXME
        }
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

- (SecKeychainItemRef)_helpSpotPasswordKeychainItem
{
    NSString *serviceName = @"Helpifier";
    NSString *accountName = [self helpSpotUsername];
    if ( [accountName length] == 0 ) return nil;
    
    UInt32 passwordLength;
    void *passwordData;
    SecKeychainItemRef item;
    OSStatus err = SecKeychainFindGenericPassword( NULL, [serviceName length], [serviceName UTF8String], [accountName length], [accountName UTF8String], &passwordLength, &passwordData, &item );
    if ( err )
    {
        return NULL;
    }
    
    return item;
}

- (NSString *)_helpSpotPasswordFromKeychain
{
    NSString *serviceName = @"Helpifier";
    NSString *accountName = [self helpSpotUsername];
    if ( [accountName length] == 0 ) return nil;
    
    UInt32 passwordLength;
    void *passwordData;
    OSStatus err = SecKeychainFindGenericPassword( NULL, [serviceName length], [serviceName UTF8String], [accountName length], [accountName UTF8String], &passwordLength, &passwordData, NULL );
    if ( err == errSecItemNotFound )
    {
        return nil;
    }
    
    return [[NSString alloc] initWithBytes:passwordData length:passwordLength encoding:NSUTF8StringEncoding];
}

@end
