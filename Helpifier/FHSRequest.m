//
//  FHSRequest.m
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
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

#import "FHSRequest.h"
#import "FHSModel.h"
#import "HelpSpotController.h"

@interface FHSRequest ()

@property (nonatomic, strong) NSMutableDictionary *thisItemProperties;

@end

#pragma mark -

@implementation FHSRequest

@synthesize requestID = _requestID;

- (void)setRequestID:(NSString *)requestID
{
    _requestID = requestID;
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.request.get&xRequest=%@", [FFSSettings sharedSettings].helpSpotBaseAPIURL, requestID]];
}

@synthesize customerName = _customerName;

@synthesize title = _title;

@synthesize previewNote = _previewNote;

@synthesize unread = _unread;

@synthesize urgent = _urgent;

@synthesize filter = _filter;

@synthesize historyItems = _historyItems;

@synthesize thisItemProperties = _thisItemProperties;

@synthesize justAdded = _justAdded;

@synthesize skeleton = _skeleton;

@synthesize standalone = _standalone;

@synthesize open = _open;

@synthesize notFound = _notFound;

- (NSInteger)mostRecentHistoryItemID
{
    if ( self.historyItems.count == 0 ) return 0;
    return [[(FHSHistoryItem *)[self.historyItems objectAtIndex:0] historyID] integerValue];
}

- (id)initWithXMLElement:(FFSXMLElement *)element delegate:(id<FHSObjectDelegate>)delegate
{
    self = [super initWithURL:nil delegate:delegate];
    if (self)
    {
        self.requestID = [element stringForKey:@"xRequest"];
        self.unread = [element boolForKey:@"isUnread"];
        self.customerName = [[element stringForKey:@"fullname"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.urgent = [element boolForKey:@"fUrgent"];
        self.title = [element stringForKey:@"sTitle"];
        self.previewNote = [element stringForKey:@"tNote"];
        self.justAdded = NO;
        self.skeleton = NO;
        self.standalone = NO;
        self.open = [element boolForKey:@"fOpen"];
        self.notFound = NO;
        
        // Requests under Subscriptions first come through with nothing but the request number, so give them dummy data and make them load.
        if ( self.title == nil )
        {
            self.title = @"…";
            self.customerName = @"";
            self.previewNote = @"";
            self.skeleton = YES;
            self.completionHandler = ^(FHSObject *sender){
                [(FHSRequest *)sender setSkeleton:NO];
                [[NSNotificationCenter defaultCenter] postNotificationName:FHSFilterDidFinishLoadingNotification
                                                                    object:nil
                                                                  userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sender, @"request", nil]];
            };
            [self fetch];
        }
    }
    return self;
}

- (id)initWithRequestID:(NSInteger)requestID delegate:(id<FHSObjectDelegate>)delegate
{
    self = [super initWithURL:nil delegate:delegate];
    if ( self )
    {
        self.requestID = [NSString stringWithFormat:@"%ld", requestID];
        self.notFound = NO;
        self.open = YES;
        self.skeleton = YES;
        self.standalone = YES;
        self.title = @"…";
        self.customerName = @"";
        self.previewNote = @"";
        self.completionHandler = ^(FHSObject *sender){
            [(FHSRequest *)sender setSkeleton:NO];
            [[NSNotificationCenter defaultCenter] postNotificationName:FHSStandaloneRequestDidFinishLoadingNotification
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:sender, @"request", nil]];
        };
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"FHSRequest #%@ (%@) %@: %@", self.requestID, self.filter.filterName, self.customerName, self.title];
}

- (void)finishedParsingXMLTree
{
    self.title = [self.xmlTree.rootElement stringForKey:@"sTitle"];
    self.customerName = [self.xmlTree.rootElement stringForKey:@"fullname"];
    self.urgent = [self.xmlTree.rootElement boolForKey:@"fUrgent"];
    self.open = [self.xmlTree.rootElement boolForKey:@"fOpen"];
    FFSXMLElement *historyElement = [self.xmlTree.rootElement firstChildWithName:@"request_history"];
    if (historyElement)
    {
        NSMutableArray *history = [NSMutableArray array];
        for (FFSXMLElement *itemElement in historyElement.children)
        {
            if ( itemElement.children.count > 0 )
            {
                FHSHistoryItem *item = [[FHSHistoryItem alloc] initWithXMLElement:itemElement];
                [history addObject:item];
            }
        }
        self.historyItems = history;
        if ( [[self.xmlTree.rootElement stringForKey:@"xCategory"] length] == 0 )
        {
            self.notFound = YES;
            [[NSNotificationCenter defaultCenter] postNotificationName:FHSRequestNotFoundNotification
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"request", nil]];
            return;
        }
        else
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:FHSRequestHistoryDidFinishLoadingNotification
                                                                object:nil
                                                              userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"request", nil]];
        }
    }
    if ( self.standalone )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:FHSStandaloneRequestDidFinishLoadingNotification
                                                            object:nil
                                                          userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"request", nil]];
    }
}

- (void)updateWithRequest:(FHSRequest *)otherRequest
{
    self.customerName = otherRequest.customerName;
    self.title = otherRequest.title;
    self.unread = otherRequest.unread;
    self.urgent = otherRequest.urgent;
}

- (void)viewOnWeb
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@admin.php?pg=request&reqid=%@", [FFSSettings sharedSettings].helpSpotBaseURL, self.requestID]]];
}

- (void)takeOnWeb
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@admin.php?pg=request&reqid=%@&frominbox=1&rand=%ld", [FFSSettings sharedSettings].helpSpotBaseURL, self.requestID, random()]]];
}

- (void)closeWithStatus:(NSInteger)status
{
    self.open = NO;
    self.url = [NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.request.update", [FFSSettings sharedSettings].helpSpotBaseAPIURL]];
    self.postData = [NSDictionary dictionaryWithObjectsAndKeys:
                     self.requestID, @"xRequest",
                     [NSString stringWithFormat:@"%ld", status], @"xStatus",
                     @"0", @"fOpen",
                     nil];
    [self fetch];
}

@end
