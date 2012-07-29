//
//  FHSObject.h
//  Helpifier
//
//  Created by Sean Dougall on 12/2/11.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
//
//	Permission is hereby granted, free of charge, to any person obtaining a copy
//	of this software and associated documentation files (the "Software"), to deal
//	in the Software without restriction, including without limitation the rights
//	to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//	copies of the Software, and to permit persons to whom the Software is
//	furnished to do so, subject to the following conditions:
//
//	The above copyright notice and this permission notice shall be included in
//	all copies or substantial portions of the Software.
//
//	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//	IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//	AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//	LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//	OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//	THE SOFTWARE.
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
