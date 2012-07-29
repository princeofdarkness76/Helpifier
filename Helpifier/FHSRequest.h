//
//  FHSRequest.h
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
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

#import "FHSObject.h"

@class FHSFilter;

@interface FHSRequest : FHSObject

@property (nonatomic, copy) NSString *requestID;
@property (nonatomic, copy) NSString *customerName;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *previewNote;
@property (nonatomic) BOOL unread;
@property (nonatomic) BOOL urgent;
@property (nonatomic, weak) FHSFilter *filter;
@property (copy) NSArray *historyItems;
@property (nonatomic) BOOL justAdded;
@property (nonatomic) BOOL skeleton;    ///< Flag to indicate that this is a newly fetched request from a subscription, in which case it will have extremely incomplete information.
@property (nonatomic) BOOL standalone;
@property (assign) BOOL open;
@property (assign) BOOL notFound;
@property (readonly) NSInteger mostRecentHistoryItemID;

- (id)initWithXMLElement:(FFSXMLElement *)element delegate:(id<FHSObjectDelegate>)delegate;
- (id)initWithRequestID:(NSInteger)requestID delegate:(id<FHSObjectDelegate>)delegate;
- (void)updateWithRequest:(FHSRequest *)otherRequest;
- (void)viewOnWeb;
- (void)takeOnWeb;
- (void)closeWithStatus:(NSInteger)status;

@end
