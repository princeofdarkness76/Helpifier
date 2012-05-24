//
//  FHSStaff.m
//  Helpifier
//
//  Created by Sean Dougall on 4/20/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
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
