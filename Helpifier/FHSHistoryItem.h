//
//  FHSHistoryItem.h
//  Helpifier
//
//  Created by Sean Dougall on 12/5/11.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FHSModel.h"
#import "FFSXML.h"

@interface FHSHistoryItem : NSObject

@property (nonatomic, weak) FHSRequest *request;
@property (copy) NSString *historyID;
@property (copy) NSString *requestID;
@property (copy) NSString *person;
@property (copy) NSString *note;
@property (copy) NSString *log;
@property (strong) NSDate *date;
@property (nonatomic) BOOL public;
@property (readonly) NSString *plainTextNote;
@property (readonly) NSString *noteWithDetails;

- (id)initWithXMLElement:(FFSXMLElement *)element;

@end
