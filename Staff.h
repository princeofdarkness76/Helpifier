//
//  Staff.h
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObject.h"


@interface Staff : DataObject 
{
    NSMutableArray          *_people;   ///< Each person is an NSDictionary.
    NSMutableDictionary     *_properties;
    NSMutableDictionary     *_thisPersonProperties;
}

+ (Staff *) staff;
- (NSMutableDictionary *) personWithEmail: (NSString *) email;

@property (retain) NSMutableDictionary *properties;
@property (retain) NSMutableArray *people;
@property (retain) NSMutableDictionary *thisPersonProperties;

@end
