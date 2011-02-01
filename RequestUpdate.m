//
//  RequestUpdate.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
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
