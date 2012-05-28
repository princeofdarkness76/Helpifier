//
//  Notifier.m
//  Helpifier
//
//  Created by Sean Dougall on 4/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "Notifier.h"
#import "FHSModel.h"
#import "HelpSpotController.h"

@interface Notifier ()

@property (assign) NSInteger attentionRequest;
@property (strong) NSMutableSet *notifyingRequestIDs;

- (void)_didReceiveUpdates:(NSNotification *)notification;
- (void)_didRemoveRequest:(NSNotification *)notification;

@end

#pragma mark -

@implementation Notifier

@synthesize attentionRequest = _attentionRequest;

@synthesize notifyingRequestIDs = _notifyingRequestIDs;

- (id)init
{
    self = [super init];
    if ( self )
    {
        _notifyingRequestIDs = [NSMutableSet set];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _didReceiveUpdates: ) name:FHSHistoryDidUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _didRemoveRequest: ) name:FHSRequestDidDisappearNotification object:nil];
        
        if ( [[NSUserDefaults standardUserDefaults] objectForKey:@"notificationBounce"] == nil )
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"notificationBounce"];
    }
    return self;
}

- (void)_didReceiveUpdates:(NSNotification *)notification
{
    NSSet *updates = [[notification.userInfo objectForKey:@"updates"] copy];
    if ( updates.count > 0 )
    {
        // Play sound whether we're in foreground or background.
        NSString *soundName = [[NSUserDefaults standardUserDefaults] valueForKey:@"notificationSound"];
        if ( soundName.length > 0 )
            [[NSSound soundNamed:soundName] play];
        
        // Bounce icon in dock if we're in the background.
        if ( ![NSApp isActive] && [[NSUserDefaults standardUserDefaults] boolForKey:@"notificationBounce"] )
        {
            _attentionRequest = [NSApp requestUserAttention:NSCriticalRequest];
            for ( FHSHistoryItem *update in updates )
            {
                [_notifyingRequestIDs addObject:update.requestID];
            }
        }
    }
}

- (void)_didRemoveRequest:(NSNotification *)notification
{
    FHSRequest *request = [notification.userInfo objectForKey:@"request"];
    if ( request )
    {
        [_notifyingRequestIDs removeObject:request.requestID];
        if ( _notifyingRequestIDs.count == 0 && _attentionRequest > 0 )
        {
            [NSApp cancelUserAttentionRequest:_attentionRequest];
            _attentionRequest = 0;
        }
    }
}

@end
