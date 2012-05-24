//
//  RequestUpdateNoticeView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/22/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "RequestUpdateNoticeView.h"

@implementation RequestUpdateNoticeView

@synthesize delegate;

- (void)drawRect:(NSRect)dirtyRect
{
    NSDrawThreePartImage( self.bounds,
                         [NSImage imageNamed:@"request-update-background-left"],
                         [NSImage imageNamed:@"request-update-background-center"],
                         [NSImage imageNamed:@"request-update-background-right"],
                         NO,
                         NSCompositeSourceOver,
                         1.0,
                         NO );
}

- (void)mouseUp:(NSEvent *)theEvent
{
    [self.delegate requestUpdateNoticeViewClicked:self];
}

@end
