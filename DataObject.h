//
//  DataObject.h
//  HelpifierData
//
//  Created by Sean Dougall on 11/14/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataRequestDelegateProtocol.h"
#import "DataObjectDelegateProtocol.h"

@class DataRequest;

@interface DataObject : NSObject <NSXMLParserDelegate, DataRequestDelegate>
{
    NSString                    *_url;
    DataRequest                 *_request;
    NSXMLParser                 *_parser;
    NSMutableString             *_thisElementString;
    BOOL                         _isFault;
    BOOL                         _errorThrown;
    
    id <DataObjectDelegate>      _delegate;
}

@property (retain) NSMutableString *thisElementString;
@property (retain) id <DataObjectDelegate> delegate;
@property (readonly) BOOL isFault;
@property (assign) BOOL errorThrown;

- (id) initWithPath: (NSString *) path;
- (void) beginFetch;

@end
