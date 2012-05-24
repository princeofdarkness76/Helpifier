//
//  FHSStaff.h
//  Helpifier
//
//  Created by Sean Dougall on 4/20/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSObject.h"

@interface FHSStaff : FHSObject

@property (copy) NSArray *people;

- (NSInteger)personWithEmail:(NSString *)email;

@end
