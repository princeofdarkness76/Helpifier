//
//  AttachmentsArrayController.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
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
