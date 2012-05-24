//
//  RequestCellView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/17/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "RequestCellView.h"

@implementation RequestCellView

@synthesize unreadImage = _unreadImage;

@synthesize subjectField = _subjectField;

@synthesize requestNumberField = _requestNumberField;

@synthesize fromField = _fromField;

- (void)viewWillDraw
{
    if ( [(NSTableRowView *)self.superview isSelected] )
    {
        self.fromField.textColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
        self.requestNumberField.textColor = [NSColor colorWithCalibratedWhite:1.0 alpha:1.0];
    }
    else
    {
        self.fromField.textColor = [NSColor colorWithCalibratedWhite:.39 alpha:1.0];
        self.requestNumberField.textColor = [NSColor colorWithCalibratedRed:57./255. green:52./255. blue:134./255. alpha:1.0];
    }
}

@end
