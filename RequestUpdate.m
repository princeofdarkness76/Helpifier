//
//  RequestUpdate.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//
//	Copyright (c) 2011 Figure 53 LLC, http://figure53.com
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

#import "RequestUpdate.h"
#import "Attachment.h"
#import "DataRequest.h"
#import "StatusCollection.h"
#import "CategoryCollection.h"
#import "HelpifierAppDelegate.h"
#import "Staff.h"

@implementation RequestUpdate

- (id) initWithRequestID: (NSString *) requestID 
                    note: (NSString *) note
             privateNote: (BOOL) isPrivate
             attachments: (NSArray *) attachments
                      cc: (NSString *) ccAddresses
                     bcc: (NSString *) bccAddresses
                  status: (NSString *) status
                category: (NSString *) category
                    tags: (NSArray *) tags
                    open: (BOOL) leaveOpen
                delegate: (id) delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        
        NSMutableString *queryString = [NSMutableString string];
        [queryString appendFormat:@"xRequest=%@", requestID];
        [queryString appendFormat:@"&tNote=%@", [note stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        [queryString appendFormat:@"&fNoteType=%d", isPrivate ? 0 : 1];
        if ([ccAddresses length] > 0)
            [queryString appendFormat:@"&email_cc=%@", [ccAddresses stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        if ([bccAddresses length] > 0)
            [queryString appendFormat:@"&email_bcc=%@", [bccAddresses stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        [queryString appendFormat:@"&xStatus=%@", [[[StatusCollection collection] statusWithTitle:status] objectForKey:@"xStatus"]];
        [queryString appendFormat:@"&fOpen=%d", leaveOpen ? 1 : 0];
        
        if ([category length] > 0)
            [queryString appendFormat:@"&xCategory=%@", [[[CategoryCollection collection] categoryWithTitle:category] objectForKey:@"xCategory"]];
        
        NSMutableArray *tagIDs = [NSMutableArray array];
        for (NSString *tagTitle in tags)
            [tagIDs addObject:[[[CategoryCollection collection] tagWithTitle:tagTitle inCategoryWithTitle:category] objectForKey:@"xReportingTag"]];
        if ([tagIDs count] > 0)
            [queryString appendFormat:@"&reportingTags=%@", [tagIDs componentsJoinedByString:@", "]];
        
        int attNum = 0;
        for (Attachment *attachment in attachments)
        {
            attNum++;
            [queryString appendFormat:@"&File%d_sFilename=%@", attNum, [attachment.name stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            [queryString appendFormat:@"&File%d_sFileMimeType=%@", attNum, attachment.mimeType];
            [queryString appendFormat:@"&File%d_bFileBody=%@", attNum, attachment.body];
        }
        
        DataRequest *req = [[DataRequest alloc] initWithURL:[NSString stringWithFormat:@"%@index.php?method=private.request.update", AppDelegate.apiURL]
                                                   postData:[NSData dataWithBytes:[queryString UTF8String] length:[queryString length]]
                                                   delegate:self];
        [req autorelease];
    }
    return self;
}

- (id) initToTakeRequestID: (NSString *) requestID
              withDelegate: (id) delegate
{
    if (self = [super init])
    {
        self.delegate = delegate;
        
        NSMutableString *queryString = [NSMutableString string];
        [queryString appendFormat:@"xRequest=%@", requestID];
        [queryString appendFormat:@"&xPersonAssignedTo=%@", [[[Staff staff] personWithEmail:AppDelegate.username] objectForKey:@"xPerson"]];
        
        DataRequest *req = [[DataRequest alloc] initWithURL:[NSString stringWithFormat:@"%@index.php?method=private.request.update", AppDelegate.apiURL]
                                                   postData:[NSData dataWithBytes:[queryString UTF8String] length:[queryString length]]
                                                   delegate:self];
        [req autorelease];
    }
    return self;
}

- (void) failedToReceiveDataWithError: (NSError *) error
{
    NSRunAlertPanel(@"Error updating request.", @"An error occurred while trying to update this request. Reason: %@", @"OK", nil, nil, [error localizedFailureReason]);
    [self.delegate dataObjectDidFailFetchWithError:[error localizedFailureReason]];
}

- (void) finishedReceivingData: (NSData *) data
{
    [self.delegate dataObjectDidFinishFetch:self];
}

@end
