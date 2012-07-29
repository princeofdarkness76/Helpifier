//
//  RequestListFooterView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/22/12.
//
//	Copyright (c) 2010-2012 Figure 53 LLC, http://figure53.com
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
