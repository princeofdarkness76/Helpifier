//
//  FFSSettings.m
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FFSSettings.h"

static FFSSettings *_sharedSettings = nil;

@implementation FFSSettings

- (NSString *)helpSpotUsername
{
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSUsername"];
}

- (NSString *)helpSpotPassword
{
    // TODO: Use keychain to store password instead.
    return [[NSUserDefaults standardUserDefaults] valueForKey:@"FHSPassword"];
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
