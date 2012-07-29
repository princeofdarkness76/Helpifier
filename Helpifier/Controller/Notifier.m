//
//  Notifier.m
//  Helpifier
//
//  Created by Sean Dougall on 4/23/12.
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
