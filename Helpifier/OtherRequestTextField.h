//
//  OtherRequestTextField.h
//  Streamers
//
//  Created by Sean Dougall on 9/12/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class HelpifierAppDelegate;

@interface OtherRequestTextField : NSTextField <NSTextFieldDelegate>

@property (weak) IBOutlet HelpifierAppDelegate *appDelegate;

@end
