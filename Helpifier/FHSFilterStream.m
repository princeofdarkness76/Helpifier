//
//  FHSFilterStream.m
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
