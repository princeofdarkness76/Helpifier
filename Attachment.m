//
//  Attachment.m
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
	
	[super dealloc];
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
    
    NSString *uti = [[NSWorkspace sharedWorkspace] typeOfFile:_localPath error:&err];
    if (uti == nil || err != nil) return @"application/octet-stream";
    
    NSString *mimeType = (NSString *)UTTypeCopyPreferredTagWithClass((CFStringRef)uti, kUTTagClassMIMEType);
    
    return [mimeType autorelease];
}

- (NSString *) body
{
    return [_fileData encodeBase64];
}

@end
