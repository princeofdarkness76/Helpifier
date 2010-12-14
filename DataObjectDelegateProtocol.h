//
//  DataObjectDelegateProtocol.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class DataObject;

@protocol DataObjectDelegate

- (void) dataObjectDidFinishFetch: (DataObject *) obj;
- (void) dataObjectDidFailFetchWithError: (NSString *) err;

@end
