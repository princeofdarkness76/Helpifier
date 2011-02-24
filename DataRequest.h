//
//  DataRequest.h
//  Helpifier
//
//  Created by Sean Dougall on 5/11/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataRequestDelegateProtocol.h"
#define kTimeoutInterval 20.0

@class DataObject;

@interface DataRequest : NSObject 
{
	NSMutableData              *_data;
	id <DataRequestDelegate>    _delegate;
	NSString                   *_url;
    NSString                   *_httpMethod;
    NSData                     *_postData;
}

@property (nonatomic, retain) id <DataRequestDelegate> delegate;

- (id) initWithURL: (NSString *) url delegate: (DataObject *) newDelegate;
- (id) initWithURL: (NSString *) url postData: (NSData *) postData delegate: (DataObject *) newDelegate;


@end
