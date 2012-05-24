//
//  FHSStatusTypeCollection.h
//  Helpifier
//
//  Created by Sean Dougall on 5/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSModel.h"
#import "FFSXML.h"

@interface FHSStatusTypeCollection : FHSObject

@property (copy) NSDictionary *statuses;

- (NSString *)statusNameForID:(NSInteger)statusID;

@end
