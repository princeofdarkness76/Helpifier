//
//  FHSSubscriptionFilter.m
//  Helpifier
//
//  Created by Sean Dougall on 4/20/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSSubscriptionFilter.h"

@implementation FHSSubscriptionFilter

- (id)initWithURL:(NSURL *)url delegate:(id<FHSObjectDelegate,NSObject>)delegate
{
    self = [super initWithURL:url delegate:delegate];
    if ( self )
    {
        self.filterID = @"__subscriptions__";
        self.filterName = @"Subscriptions";
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.request.subscriptions", [FFSSettings sharedSettings].helpSpotBaseAPIURL]];
    }
    return self;
}

- (void)fetch
{
    if ( self.delegate.personID == NSNotFound ) return;
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.request.subscriptions&xPerson=%lu", [FFSSettings sharedSettings].helpSpotBaseAPIURL, self.delegate.personID]];
    [super fetch];
}

- (void)finishedParsingXMLTree
{
    [super finishedParsingXMLTree];
}

@end
