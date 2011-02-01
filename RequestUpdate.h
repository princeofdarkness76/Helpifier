//
//  RequestUpdate.h
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DataObject.h"


@interface RequestUpdate : DataObject
{
    NSString        *_requestID;
    NSString        *_note;
    NSArray         *_attachments;
}

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
                delegate: (id) delegate;

- (id) initToTakeRequestID: (NSString *) requestID
              withDelegate: (id) delegate;

@end
