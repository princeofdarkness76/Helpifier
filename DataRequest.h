//
//  DataRequest.h
//  ChromaData
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
}

@property (nonatomic, retain) id <DataRequestDelegate> delegate;

- (id) initWithURL: (NSString *) url delegate: (id) newDelegate;


@end
