//
//  FFSSettings.m
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
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
