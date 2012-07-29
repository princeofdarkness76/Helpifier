//
//  FHSFilter.m
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

#import "FHSFilter.h"
#import "FHSModel.h"
#import "HelpSpotController.h"

@interface FHSFilter ()

@property (nonatomic, strong) NSMutableDictionary *thisRequestProperties;
@property (nonatomic) BOOL private_fetchInProgress;
@property (nonatomic, strong) NSMutableDictionary *private_expiredRequests;
@property (nonatomic, strong) NSMutableDictionary *private_expiredRequestIndexes;
@property (assign) NSInteger mostRecentHistoryID;
@property (strong) FHSFilterStream *filterStream;
@property (strong) FHSFilterStream *filterStreamPrivate;

@end

#pragma mark -

@implementation FHSFilter

@synthesize filterID = _filterID;

- (void)setFilterID:(NSString *)filterID
{
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.filter.get&xFilter=%@", [FFSSettings sharedSettings].helpSpotBaseAPIURL, filterID]];
    _filterID = filterID;
}

@synthesize filterName = _filterName;

@synthesize requests = _requests;

- (NSArray *)sortedRequestIDs
{
    // Sorted by request number, treated as integer, descending.
    return [[self.requests allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2){
        if ([obj1 integerValue] < [obj2 integerValue])
            return NSOrderedDescending;
        if ([obj1 integerValue] > [obj2 integerValue])
            return NSOrderedAscending;
        return NSOrderedSame;
    }];
}

- (NSDictionary *)expiredRequests
{
    return [self.private_expiredRequests copy];
}

- (NSDictionary *)expiredRequestIndexes
{
    return [self.private_expiredRequestIndexes copy];
}

- (NSUInteger)unreadCount
{
    NSUInteger result = 0;
    for (NSString *requestID in [self.requests allKeys])
    {
        if ([(FHSRequest *)[self.requests objectForKey:requestID] unread])
            result++;
    }
    return result;
}

- (BOOL)isInbox
{
    return ( [self.filterID isEqualToString:@"inbox"] );
}

- (BOOL)fetchInProgress
{
    return self.private_fetchInProgress;
}

@synthesize thisRequestProperties = _thisRequestProperties;

@synthesize private_fetchInProgress = _private_fetchInProgress;

@synthesize private_expiredRequests = _private_expiredRequests;

@synthesize private_expiredRequestIndexes = _private_expiredRequestIndexes;

@synthesize shouldCheckFilterStream = _shouldCheckFilterStream;

@synthesize filterStream = _filterStream;

@synthesize filterStreamPrivate = _filterStreamPrivate;

@synthesize mostRecentHistoryID = _mostRecentHistoryID;

- (id)initWithURL:(NSURL *)url delegate:(id<FHSObjectDelegate>)delegate
{
    self = [super initWithURL:url delegate:delegate];
    if (self)
    {
        self.filterStream = [[FHSFilterStream alloc] initWithURL:nil delegate:self];
        self.filterStream.filter = self;
        self.filterStream.stream = @"stream";
        self.filterStreamPrivate = [[FHSFilterStream alloc] initWithURL:nil delegate:self];
        self.filterStreamPrivate.filter = self;
        self.filterStreamPrivate.stream = @"stream-priv";
        self.requests = [NSMutableDictionary dictionary];
        self.private_fetchInProgress = NO;
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"FHSFilter at %@", self.url];
}

- (void)fetch
{
    [[NSNotificationCenter defaultCenter] postNotificationName:FHSFilterDidBeginLoadingNotification object:nil userInfo:nil];
    _private_fetchInProgress = YES;
    [super fetch];
    if ( self.shouldCheckFilterStream )
    {
        [self.filterStream fetch];
        [self.filterStreamPrivate fetch];
    }
}

- (void)finishedParsingXMLTree
{
    // Cache the old index of each request, so that we know where to remove from the list later.
    NSMutableDictionary *oldIndexesByRequestID = [NSMutableDictionary dictionary];
    NSInteger i;
    for ( i = 0; i < self.sortedRequestIDs.count; i++ )
    {
        [oldIndexesByRequestID setObject:[NSNumber numberWithInteger:i] forKey:[self.sortedRequestIDs objectAtIndex:i]];
    }
    
    // Create a new list of the requests we just got.
    NSMutableDictionary *fetchedRequests = [NSMutableDictionary dictionary];
    FFSXMLElement *filter = self.xmlTree.rootElement;
    for (FFSXMLElement *requestElement in filter.children)
    {
        FHSRequest *request = [[FHSRequest alloc] initWithXMLElement:requestElement delegate:self];
        if (request.requestID)  // An empty request element will come through if the filter is empty.
        {
            request.filter = self;
            [fetchedRequests setObject:request forKey:request.requestID];
        }
    }
    
    // Add new requests we didn't already know about, and update parameters of old requests.
    for (NSString *requestID in [fetchedRequests allKeys])
    {
        if ([self.requests objectForKey:requestID] == nil)
        {
            [[fetchedRequests objectForKey:requestID] setJustAdded:YES];
            [self.requests setObject:[fetchedRequests objectForKey:requestID] forKey:requestID];
        }
        else if ([(FHSRequest *)[fetchedRequests objectForKey:requestID] skeleton])
        {
            [[self.requests objectForKey:requestID] fetch];
        }
        else
        {
            [[self.requests objectForKey:requestID] updateWithRequest:[fetchedRequests objectForKey:requestID]];
        }
    }
    
    // Remove requests that no longer appear in this filter.
    _private_expiredRequestIndexes = [NSMutableDictionary dictionary];
    _private_expiredRequests = [NSMutableDictionary dictionary];
    for (NSString *requestID in [self.requests allKeys])
    {
        if ([fetchedRequests objectForKey:requestID] == nil)
        {
            [_private_expiredRequestIndexes setObject:[oldIndexesByRequestID objectForKey:requestID] forKey:requestID];
            [_private_expiredRequests setObject:[self.requests objectForKey:requestID] forKey:requestID];
        }
    }
    [self.requests removeObjectsForKeys:[_private_expiredRequestIndexes allKeys]];
    
    // Send notifications for all requests we just removed.
    for (FHSRequest *request in [_private_expiredRequests allValues] )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:FHSRequestDidDisappearNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:request, @"request", nil]];
    }
    
    _private_fetchInProgress = NO;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:FHSFilterDidFinishLoadingNotification
                                                        object:nil
                                                      userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"filter", nil]];
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

- (NSTimeInterval)timeIntervalBeforeReloadForObject:(FHSObject *)object
{
    return [self.delegate timeIntervalBeforeReloadForObject:object];
}

- (void)object:(FHSObject *)object didFinishParsingXMLTree:(FFSXMLTree *)tree
{
    if ( object == self.filterStream )
    {
        // TODO: do something with this information
    }
}

@end
