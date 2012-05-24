//
//  FHSFilterStream.h
//  Helpifier
//
//  Created by Sean Dougall on 4/23/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "FHSModel.h"

@interface FHSFilterStream : FHSObject

@property (assign) NSInteger mostRecentHistoryID;
@property (weak) FHSFilter *filter;
@property (copy) NSString *stream;

@end
