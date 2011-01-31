//
//  Attachment.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import "Attachment.h"
#import "NSString+Base64.h"


@implementation Attachment

+ (Attachment *) attachmentWithFileAtPath: (NSString *) path
{
    return [[[Attachment alloc] initWithFileAtPath:path] autorelease];
}

- (id) initWithFileAtPath: (NSString *) path
{
    if (self = [super init])
    {
        NSError *err = nil;
        
        _localPath = [path retain];
        _fileData = [[NSData dataWithContentsOfURL:[NSURL fileURLWithPath:path] options:0 error:&err] retain];
        if (err)
        {
            NSRunAlertPanel(@"Error reading file.", @"An error occurred while trying to read the file at %@. Reason: %@.", @"OK", nil, nil, path, [err localizedFailureReason]);
            _fileData = nil;
        }
    }
    return self;
}

- (void) dealloc
{
    [_localPath release];
    _localPath = nil;
    
    [_fileData release];
    _fileData = nil;
}

- (NSString *) name
{
    return [[_localPath pathComponents] lastObject];
}

- (NSString *) size
{
    NSUInteger dataSize = [_fileData length];
    
    if (dataSize < 1024)
        return [NSString stringWithFormat:@"%d byte%@", dataSize, dataSize == 1 ? @"" : @"s"];
    
    if (dataSize < 1024 * 1024)
        return [NSString stringWithFormat:@"%0.1f kB", (float)dataSize / 1024.0];
    
    if (dataSize < 1024 * 1024 * 1024)
        return [NSString stringWithFormat:@"%0.1f MB", (float)dataSize / (1024.0 * 1024.0)];
    
    return [NSString stringWithFormat:@"%0.1f GB", (float)dataSize / (1024.0 * 1024.0 * 1024.0)];
}

- (NSString *) mimeType 
{
    NSError *err = nil;
    
    NSString *uti = [[NSWorkspace sharedWorkspace] typeOfFile:_localPath error:err];
    if (uti == nil || err != nil) return @"application/octet-stream";
    
    NSString *mimeType = (NSString *)UTTypeCopyPreferredTagWithClass((CFStringRef)uti, kUTTagClassMIMEType);
    
    return [mimeType autorelease];
}

- (NSString *) body
{
    return [_fileData encodeBase64];
}

@end
