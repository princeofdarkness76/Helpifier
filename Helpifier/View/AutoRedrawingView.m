//
//  AutoRedrawingView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/22/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "AutoRedrawingView.h"

@interface AutoRedrawingView ()

- (void)_redraw:(NSNotification *)notification;

@end

#pragma mark -

@implementation AutoRedrawingView

- (void)awakeFromNib
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _redraw: ) name:NSWindowDidBecomeMainNotification object:self.window];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector( _redraw: ) name:NSWindowDidResignMainNotification object:self.window];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)_redraw:(NSNotification *)notification
{
    if ( notification.object == self.window )
        [self setNeedsDisplay:YES];
}

@end
