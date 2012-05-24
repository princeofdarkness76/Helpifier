//
//  OtherRequestTextField.m
//  Streamers
//
//  Created by Sean Dougall on 9/12/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "OtherRequestTextField.h"
#import "HelpifierAppDelegate.h"

@implementation OtherRequestTextField

@synthesize appDelegate = _appDelegate;

- (void)viewWillMoveToSuperview:(NSView *)newSuperview
{
    self.delegate = self;
}

- (BOOL) performKeyEquivalent: (NSEvent *) theEvent
{
    // On return or enter, relinquish first responder and go to that request.
    if ([theEvent keyCode] == 36 || [theEvent keyCode] == 76)
    {
        [_appDelegate goToOtherRequest:self.integerValue];
        return YES;
    }
    
    return [super performKeyEquivalent:theEvent];
}

#pragma mark - NSTextFieldDelegate

- (BOOL)control:(NSControl *)control textView:(NSTextView *)textView doCommandBySelector:(SEL)commandSelector
{
    if ( commandSelector == @selector( cancelOperation: ) )
    {
        self.stringValue = @"";
        [_appDelegate dismissOtherRequest];
        return YES;
    }
    return NO;
}

@end
