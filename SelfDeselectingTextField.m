//
//  SelfDeselectingTextField.m
//  Adapted from Streamers
//
//  Created by Sean Dougall on 9/12/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "SelfDeselectingTextField.h"

@implementation SelfDeselectingTextField

- (BOOL) performKeyEquivalent: (NSEvent *) theEvent
{
    // On return or enter, relinquish first responder and tell undo controller that editing has stopped
    if ([theEvent keyCode] == 36 || [theEvent keyCode] == 76)
    {
        [[self window] makeFirstResponder:[[self window] initialFirstResponder]];
        return YES;
    }
    return [super performKeyEquivalent:theEvent];
}

@end
