//
//  HelpifierAppDelegate.m
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "HelpifierAppDelegate.h"
#import "DataHeaders.h"
#import "DataRequest.h"
#import "NSData+NSString.h"
#import "RequestController.h"

@implementation HelpifierAppDelegate

@synthesize window = _window;
@synthesize prefsWindow = _prefsWindow;
@synthesize requestController = _requestController;

- (void) applicationDidFinishLaunching: (NSNotification *) aNotification 
{
    _notifiedUnreadRequests = [[NSMutableDictionary dictionary] retain];
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setBool:YES forKey:@"showFilter_inbox"];
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setBool:YES forKey:@"showFilter_myq"];
}

- (void) dealloc
{
    [_notifiedUnreadRequests release];
    _notifiedUnreadRequests = nil;
    
    [super dealloc];
}

- (NSString *) username
{
    return [[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"username"];
}

- (void) setUsername: (NSString *) newUsername {}

- (NSString *) password
{
    return [[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"password"];
}

- (void) setApiURL: (NSString *) newURL {}

- (NSString *) apiURL
{
    NSString *storedURL = [[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"apiURL"];
    if (!storedURL || [storedURL length] == 0)
        storedURL = [NSString stringWithFormat:@"%@api/", self.supportURL];
    NSMutableString *url = [[storedURL mutableCopy] autorelease];
    if ([url rangeOfString:@"http://"].location == NSNotFound && [url rangeOfString:@"https://"].location == NSNotFound)
        [url insertString:@"http://" atIndex:0];
    if ([url characterAtIndex:[url length] - 1] != '/')
        [url appendString:@"/"];
    return [[url copy] autorelease];
}

- (void) setSupportURL: (NSString *) newURL {}

- (NSString *) supportURL
{
    NSMutableString *url = [[[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"supportURL"] mutableCopy] autorelease];
    if ([url rangeOfString:@"http://"].location == NSNotFound && [url rangeOfString:@"https://"].location == NSNotFound)
        [url insertString:@"http://" atIndex:0];
    if ([url characterAtIndex:[url length] - 1] != '/')
        [url appendString:@"/"];
    return [[url copy] autorelease];
}

- (void) setPassword: (NSString *) newPassword {}

- (void) setUnreadRequests: (NSDictionary *) newRequests notify: (BOOL) shouldNotify
{
    BOOL needToNotify = NO;
    for (id reqID in [newRequests allKeys])
    {
        if ([_notifiedUnreadRequests objectForKey:reqID] == nil 
            || [[_notifiedUnreadRequests objectForKey:reqID] compare:[newRequests objectForKey:reqID]] == NSOrderedAscending)
        {
            [_notifiedUnreadRequests setObject:[newRequests objectForKey:reqID] forKey:reqID];
            needToNotify = YES;
        }
    }
    
    if (needToNotify && shouldNotify)
    {
        _attentionRequest = [NSApp requestUserAttention:NSCriticalRequest];
        if ([[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"notificationSound"])
            [[NSSound soundNamed:[[[NSUserDefaultsController sharedUserDefaultsController] defaults] valueForKey:@"notificationSound"]] play];
    }

    if (!needToNotify && _attentionRequest > 0)
    {
        [NSApp cancelUserAttentionRequest:_attentionRequest];
        _attentionRequest = 0;
    }

    if ([[newRequests allKeys] count] > 0)
        [[NSApp dockTile] setBadgeLabel:[NSString stringWithFormat:@"%d", [[newRequests allKeys] count]]];
    else
        [[NSApp dockTile] setBadgeLabel:@""];
}

#pragma mark -
#pragma mark actions

- (IBAction) help: (id) sender
{
	NSRunAlertPanel(@"Help is not available for Helpifier.", @"Come now. That would just be too meta.", @"OK", nil, nil);
}

- (IBAction) showPreferences: (id) sender
{
	[_prefsWindow makeKeyAndOrderFront:sender];
}

- (IBAction) chooseSystemSound: (id) sender
{
    [[[NSUserDefaultsController sharedUserDefaultsController] defaults] setValue:[sender title] forKey:@"notificationSound"];
    [[NSSound soundNamed:[sender title]] play];
}

@end
