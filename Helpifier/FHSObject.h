//
//  FHSObject.h
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FFSSettings.h"
#import "FFSXML.h"

@class FHSObject;

typedef void (^FHSObjectCompletionHandler)(FHSObject *sender);

@protocol FHSObjectDelegate <NSObject>

- (NSString *)username;
- (NSString *)password;

@optional
- (NSInteger)personID;
- (NSTimeInterval)timeIntervalBeforeReloadForObject:(FHSObject *)object;
- (void)object:(FHSObject *)object didFinishReceivingData:(NSData *)data;
- (void)object:(FHSObject *)object didFinishParsingXMLTree:(FFSXMLTree *)tree;
- (void)object:(FHSObject *)object didFailToReceiveDataWithError:(NSError *)error;

@end

#pragma mark -

@interface FHSObject : NSObject <NSXMLParserDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <FHSObjectDelegate> delegate;
@property (copy) NSDictionary *postData;
@property (nonatomic, strong) NSDate *lastFetchDate;
@property (nonatomic, strong) FFSXMLTree *xmlTree;
@property (copy) FHSObjectCompletionHandler completionHandler;
@property (strong) NSTimer *refreshTimer;

- (id)initWithURL:(NSURL *)url delegate:(id <FHSObjectDelegate, NSObject>)delegate;
- (void)fetch;
- (void)fetchAfterAppropriateDelay;

// -finishedParsingXMLTree will be called when the XML is finished being parsed (which happens on a background queue).
//     Never call this directly!
//     Subclasses may override this to get notified of when they're done parsing.
//
- (void)finishedParsingXMLTree;

@end
