//
//  CategoryCollection.h
//  Helpifier
//
//  Created by Sean Dougall on 1/31/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObject.h"


@interface CategoryCollection : DataObject
{
    NSMutableArray          *_categories;   ///< Each category is an NSDictionary.
    NSMutableDictionary     *_properties;
    NSMutableDictionary     *_thisCategoryProperties;
    NSMutableDictionary     *_thisTagProperties;
}

+ (CategoryCollection *) collection;
- (NSMutableDictionary *) categoryWithTitle: (NSString *) title;
- (NSMutableDictionary *) tagWithTitle: (NSString *) tagTitle inCategoryWithTitle: (NSString *) categoryTitle;

@property (retain) NSMutableDictionary *properties;
@property (retain) NSMutableArray *categories;
@property (retain) NSMutableDictionary *thisCategoryProperties;
@property (retain) NSMutableDictionary *thisTagProperties;

@end
