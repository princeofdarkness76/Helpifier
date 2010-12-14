//
//  DataRequestDelegateProtocol.h
//  Helpifier
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@protocol DataRequestDelegate

- (void) failedToReceiveDataWithError: (NSError *) error;
- (void) finishedReceivingData: (NSData *) data;

@end
