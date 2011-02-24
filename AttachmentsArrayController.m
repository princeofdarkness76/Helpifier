//
//  AttachmentsArrayController.m
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

#import "AttachmentsArrayController.h"
#import "Attachment.h"


@implementation AttachmentsArrayController

- (NSDragOperation) tableView: (NSTableView *) aTableView
                 validateDrop: (id < NSDraggingInfo >) info
                  proposedRow: (NSInteger) row
        proposedDropOperation: (NSTableViewDropOperation) operation
{
    NSPasteboard *pboard = [info draggingPasteboard];
    
    if ([[pboard types] containsObject:NSFilenamesPboardType]) 
    {
        return NSDragOperationCopy;
    }
    return NSDragOperationNone;
}

- (BOOL) tableView: (NSTableView *) aTableView
        acceptDrop: (id < NSDraggingInfo >) info
               row: (NSInteger) row
     dropOperation: (NSTableViewDropOperation) operation
{
    NSArray *files = [[info draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    for (NSString *path in files)
    {
        [self addObject:[Attachment attachmentWithFileAtPath:path]];
    }
    return YES;
}

- (IBAction) add: (id) sender
{
    NSOpenPanel *op = [NSOpenPanel openPanel];
    [op setAllowsMultipleSelection:YES];
    if ([op runModal] == NSFileHandlingPanelOKButton)
    {
        for (NSString *path in [op filenames])
            [self addObject:[Attachment attachmentWithFileAtPath:path]];
    }
}

@end
