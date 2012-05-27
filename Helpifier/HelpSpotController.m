//
//  HelpSpotController.m
//  Helpifier
//
//  Created by Sean Dougall on 12/4/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "HelpSpotController.h"
#import "FFSSettings.h"

#define TIME_INTERVAL_BETWEEN_FULL_REFRESHES 20.0
#define TIME_INTERVAL_AFTER_ERROR 30.0
#define TIME_INTERVAL_BETWEEN_SUBSCRIPTION_REQUEST_REFRESHES 60.0
#define TIME_INTERVAL_BETWEEN_CURRENT_REQUEST_REFRESHES 20.0

@interface HelpSpotController () <FHSObjectDelegate>

@property (assign) BOOL shouldKeepRefreshing;

@end

#pragma mark -

@implementation HelpSpotController

@synthesize staff = _staff;

@synthesize inboxFilter = _inboxFilter;

@synthesize myQueueFilter = _myQueueFilter;

@synthesize subscriptionFilter = _subscriptionFilter;

@synthesize statusTypes = _statusTypes;

- (NSInteger)personID
{
    if ( self.staff )
    {
        return [self.staff personWithEmail:self.username];
    }
    return NSNotFound;
}

- (NSUInteger)totalUnreadCount
{
    return self.inboxFilter.requests.count + self.myQueueFilter.unreadCount + self.subscriptionFilter.unreadCount;
}

- (NSArray *)allRequests
{
    NSMutableSet *requests = [NSMutableSet set];
    for ( FHSRequest *request in self.inboxFilter.requests.allValues )
        [requests addObject:request];
    for ( FHSRequest *request in self.myQueueFilter.requests.allValues )
        [requests addObject:request];
    for ( FHSRequest *request in self.subscriptionFilter.requests.allValues )
        [requests addObject:request];
    return [requests allObjects];
}

@synthesize lastError = _lastError;

- (void)setLastError:(NSString *)lastError
{
    _lastError = [lastError copy];
    [[NSNotificationCenter defaultCenter] postNotificationName:FHSErrorDidChangeNotification object:nil userInfo:nil];
}

@synthesize shouldKeepRefreshing = _shouldKeepRefreshing;

- (NSTimeInterval)timeIntervalBeforeReloadForObject:(FHSObject *)object
{
    if ( self.lastError )
        return TIME_INTERVAL_AFTER_ERROR;
    
    if ( [object isKindOfClass:[FHSRequest class]] )
    {
        FHSRequest *request = (FHSRequest *)object;
        if ( request.filter == self.subscriptionFilter )
        {
            return TIME_INTERVAL_BETWEEN_SUBSCRIPTION_REQUEST_REFRESHES;
        }
        else
        {
//            return -1;
            return TIME_INTERVAL_BETWEEN_CURRENT_REQUEST_REFRESHES;
        }
    }
    
    return TIME_INTERVAL_BETWEEN_FULL_REFRESHES;
}

- (void)refresh
{
    if (self.username.length == 0 || self.password.length == 0)
    {
        NSLog( @"Attempt to fetch without username/password." );
        [[NSNotificationCenter defaultCenter] postNotificationName:FHSAuthenticationInformationNeededNotification object:nil userInfo:nil];
        return;
    }
    
    if (!self.inboxFilter)
    {
        self.inboxFilter = [[FHSFilter alloc] initWithURL:nil delegate:self];
        self.inboxFilter.filterName = @"Inbox";
        self.inboxFilter.filterID = @"inbox";
        self.inboxFilter.delegate = self;
        self.inboxFilter.shouldCheckFilterStream = YES;
        self.myQueueFilter = [[FHSFilter alloc] initWithURL:nil delegate:self];
        self.myQueueFilter.filterName = @"My Queue";
        self.myQueueFilter.filterID = @"myq";
        self.myQueueFilter.delegate = self;
        self.myQueueFilter.shouldCheckFilterStream = YES;
        self.subscriptionFilter = [[FHSSubscriptionFilter alloc] initWithURL:nil delegate:self];
        
        // Get staff. We won't be able to fetch subscriptions until we get the staff, so set our first subscription fetch up as a completion handler.
        __block HelpSpotController *controller = self;
        self.staff = [[FHSStaff alloc] initWithURL:nil delegate:self];
        self.staff.delegate = self;
        self.staff.completionHandler = ^(FHSObject *sender){
            [controller.subscriptionFilter fetch];
        };
        [self.staff fetch];
    }
    
    [self.inboxFilter fetch];
    [self.myQueueFilter fetch];
    [self.subscriptionFilter fetch];
    
    if (!self.statusTypes)
    {
        self.statusTypes = [[FHSStatusTypeCollection alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.request.getStatusTypes", [FFSSettings sharedSettings].helpSpotBaseAPIURL]] delegate:self];
        [self.statusTypes fetch];
    }
}

- (void)start
{
    self.shouldKeepRefreshing = YES;
    [self refresh];
}

#pragma mark - FHSObjectDelegate

- (NSString *)username
{
    return [FFSSettings sharedSettings].helpSpotUsername;
}

- (NSString *)password
{
    return [FFSSettings sharedSettings].helpSpotPassword;
}

- (void)object:(FHSObject *)object didFinishReceivingData:(NSData *)data
{
    if ( self.shouldKeepRefreshing && [object isKindOfClass:[FHSFilter class]] )
    {
        [object fetchAfterAppropriateDelay];
    }
    else if ( [object isKindOfClass:[FHSStatusTypeCollection class]] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:FHSStatusTypeCollectionDidFinishLoadingNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:object, @"statusTypes", nil]];
    }
    self.lastError = nil;
}

- (void)object:(FHSObject *)object didFailToReceiveDataWithError:(NSError *)error
{
    if ( [[NSUserDefaults standardUserDefaults] boolForKey:@"FHSDebugErrors"] )
        NSLog( @"Got error (%@) from %@", error.localizedDescription, object );
    
    self.lastError = error.localizedDescription;

    if ( self.shouldKeepRefreshing && [object isKindOfClass:[FHSFilter class]] )
    {
        [object fetchAfterAppropriateDelay];
    }
    else if ( [object isKindOfClass:[FHSStatusTypeCollection class]] )
    {
        [object fetchAfterAppropriateDelay];
    }
}

@end
