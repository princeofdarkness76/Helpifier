//
//  FHSFilterStream.m
//  Helpifier
//
//  Created by Sean Dougall on 4/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSFilterStream.h"
#import "HelpSpotController.h"

@implementation FHSFilterStream

@synthesize mostRecentHistoryID = _mostRecentHistoryID;

@synthesize filter = _filter;

@synthesize stream = _stream;

- (void)fetch
{
    if ( !self.stream )
        self.stream = @"stream";
    
    if ( self.mostRecentHistoryID > 0 )
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.filter.getStream&sFilterView=%@&xFilter=%@&fromRequestHistory=%ld", [FFSSettings sharedSettings].helpSpotBaseAPIURL, self.stream, self.filter.filterID, _mostRecentHistoryID]];
    else
        self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.filter.getStream&sFilterView=%@&xFilter=%@&limit=1", [FFSSettings sharedSettings].helpSpotBaseAPIURL, self.stream, self.filter.filterID]];
    
    [super fetch];
}

- (void)finishedParsingXMLTree
{
    if ( [self.xmlTree.rootElement.name isEqualToString:@"stream"] )
    {
        NSMutableSet *newUpdates = [NSMutableSet set];
        NSInteger latestHistoryID = 0;
        for ( FFSXMLElement *historyNote in self.xmlTree.rootElement.children )
        {
            if ( historyNote.children.count == 0 ) continue; ///< If there are no new requests, we get a blank history_note element that needs to be ignored.
            NSInteger historyID = [historyNote integerForKey:@"xRequestHistory"];
            latestHistoryID = MAX( latestHistoryID, historyID );
            FHSHistoryItem *item = [[FHSHistoryItem alloc] initWithXMLElement:historyNote];
            item.request = [self.filter.requests objectForKey:[NSNumber numberWithInteger:[historyNote integerForKey:@"xRequest"]]];
            [newUpdates addObject:item];
        }
        if ( self.mostRecentHistoryID > 0 && newUpdates.count > 0 )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:FHSHistoryDidUpdateNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:
                                                                                                                            newUpdates, @"updates",
                                                                                                                            nil]];
        }
        self.mostRecentHistoryID = MAX( latestHistoryID, self.mostRecentHistoryID );
    }
}

@end
