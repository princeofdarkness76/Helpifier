//
//  FFSSettings.h
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FFSSettings : NSObject

// HelpSpot
@property (readonly) NSString *helpSpotUsername;
@property (readonly) NSString *helpSpotPassword;
@property (readonly) NSURL *helpSpotBaseURL;
@property (readonly) NSURL *helpSpotBaseAPIURL;

// Shared
@property (readonly) float timeoutInterval;

+ (FFSSettings *)sharedSettings;

@end
