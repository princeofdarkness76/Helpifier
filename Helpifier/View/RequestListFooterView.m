//
//  RequestListFooterView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/22/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import "RequestListFooterView.h"

@interface RequestListFooterView ()

@property (strong) NSGradient *activeGradient;

@property (strong) NSGradient *inactiveGradient;

- (void)_drawSeparatorAtX:(CGFloat)x;

@end

#pragma mark -

@implementation RequestListFooterView

@synthesize activeGradient = _activeGradient;

@synthesize inactiveGradient = _inactiveGradient;

- (void)drawRect:(NSRect)dirtyRect
{
    if ( !_activeGradient )
        _activeGradient = [[NSGradient alloc] initWithColorsAndLocations:
                           [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], 0.0,
                           [NSColor colorWithCalibratedWhite:0.72 alpha:1.0], 0.03,
                           [NSColor colorWithCalibratedWhite:0.77 alpha:1.0], 0.5,
                           [NSColor colorWithCalibratedWhite:0.6 alpha:1.0], 0.5,
                           [NSColor colorWithCalibratedWhite:0.45 alpha:1.0], 1.0,
                           nil];
    
    if ( !_inactiveGradient )
        _inactiveGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], 0.0,
                             [NSColor colorWithCalibratedWhite:0.74 alpha:1.0], 0.03,
                             [NSColor colorWithCalibratedWhite:0.77 alpha:1.0], 0.5,
                             [NSColor colorWithCalibratedWhite:0.66 alpha:1.0], 0.5,
                             [NSColor colorWithCalibratedWhite:0.63 alpha:1.0], 1.0,
                             nil];
    
    if ( self.window.isMainWindow )
    {
        [_activeGradient drawInRect:self.frame angle:-90];
    }
    else
    {
        [_inactiveGradient drawInRect:self.frame angle:-90];
    }
    
    [self _drawSeparatorAtX:36];
}

- (void)_drawSeparatorAtX:(CGFloat)x
{
    CGContextRef context = self.window.graphicsContext.graphicsPort;
    CGContextSetGrayFillColor( context, 0.4, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, x, 4 );
    CGContextAddLineToPoint( context, x - 0.5, 18 );
    CGContextAddLineToPoint( context, x, 32 );
    CGContextClosePath( context );
    CGContextFillPath( context );
    CGContextSetGrayFillColor( context, 1.0, 1.0 );
    CGContextBeginPath( context );
    CGContextMoveToPoint( context, x, 4 );
    CGContextAddLineToPoint( context, x + 0.5, 18 );
    CGContextAddLineToPoint( context, x, 32 );
    CGContextClosePath( context );
    CGContextFillPath( context );
}

@end
