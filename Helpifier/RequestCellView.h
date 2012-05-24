//
//  RequestCellView.h
//  Helpifier
//
//  Created by Sean Dougall on 4/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface RequestCellView : NSTableCellView

@property (strong) IBOutlet NSImageView *unreadImage;
@property (strong) IBOutlet NSTextField *subjectField;
@property (strong) IBOutlet NSTextField *requestNumberField;
@property (strong) IBOutlet NSTextField *fromField;

@end
