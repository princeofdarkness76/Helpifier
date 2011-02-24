//
//  Attachment.h
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface Attachment : NSObject 
{
    NSString        *_localPath;
    NSData          *_fileData;
}

@property (readonly) NSString *name;
@property (readonly) NSString *size;
@property (readonly) NSString *mimeType;
@property (readonly) NSString *body;

+ (Attachment *) attachmentWithFileAtPath: (NSString *) path;
- (id) initWithFileAtPath: (NSString *) path;

@end
