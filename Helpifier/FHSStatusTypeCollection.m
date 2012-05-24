//
//  FHSStatusTypeCollection.m
//  Helpifier
//
//  Created by Sean Dougall on 5/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSStatusTypeCollection.h"

@implementation FHSStatusTypeCollection

@synthesize statuses = _statuses;

- (void)finishedParsingXMLTree
{
    NSMutableDictionary *newStatuses = [NSMutableDictionary dictionary];
    for ( FFSXMLElement *status in self.xmlTree.rootElement.children )
    {
        if ( [[status stringForKey:@"sStatus"] isEqualToString:@"Active"] )
            continue;
        [newStatuses setObject:[status stringForKey:@"sStatus"] forKey:[NSNumber numberWithInteger:[status integerForKey:@"xStatus"]]];
    }
    self.statuses = newStatuses;
}

- (NSString *)statusNameForID:(NSInteger)statusID
{
    return [self.statuses objectForKey:[NSNumber numberWithInteger:statusID]];
}

@end
