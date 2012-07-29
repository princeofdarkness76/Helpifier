//
//  FHSStaff.m
//  Helpifier
//
//  Created by Sean Dougall on 4/20/12.
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

#import "FHSStaff.h"

@implementation FHSStaff

@synthesize people = _people;

- (id)initWithURL:(NSURL *)url delegate:(id<FHSObjectDelegate,NSObject>)delegate
{
    self = [super initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@index.php?method=private.util.getActiveStaff", [FFSSettings sharedSettings].helpSpotBaseAPIURL]] delegate:delegate];
    if ( self )
    {
        
    }
    return self;
}

- (NSInteger)personWithEmail:(NSString *)email
{
    if ( !_people )
        return NSNotFound;
    
    for ( NSDictionary *person in _people )
    {
        for ( NSString *thisEmail in [person objectForKey:@"emails"] )
        {
            if ( [thisEmail isEqualToString:email] )
                return [[person objectForKey:@"xPerson"] integerValue];
        }
    }
    return NSNotFound;
}

- (void)finishedParsingXMLTree
{
    NSMutableArray *newPeople = [NSMutableArray array];
    FFSXMLElement *staffElement = self.xmlTree.rootElement;
    for ( FFSXMLElement *personElement in staffElement.children )
    {
        NSMutableDictionary *person = [NSMutableDictionary dictionary];
        NSMutableArray *emails = [NSMutableArray array];
        if ( [personElement stringForKey:@"sEmail"] )
            [emails addObject:[personElement stringForKey:@"sEmail"]];
        int i = 2;
        while ( [[personElement stringForKey:[NSString stringWithFormat:@"sEmail%d", i]] length] != 0 )
        {
            [emails addObject:[personElement stringForKey:[NSString stringWithFormat:@"sEmail%d", i]]];
            i++;
        }
        [person setObject:emails forKey:@"emails"];
        [person setObject:[NSNumber numberWithInteger:[personElement integerForKey:@"xPerson"]] forKey:@"xPerson"];
        if ( [personElement stringForKey:@"fullname"] )
            [person setObject:[personElement stringForKey:@"fullname"] forKey:@"fullname"];
        [newPeople addObject:person];
    }
    self.people = newPeople;
}

@end
