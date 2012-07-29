//
//  RequestBackgroundView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/13/12.
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

#import "RequestBackgroundView.h"

@interface RequestBackgroundView ()

@property (strong) NSColor *activeColor;

@property (strong) NSGradient *activeGradient;

@property (strong) NSColor *inactiveColor;

@property (strong) NSGradient *inactiveGradient;

@end

#pragma mark -

@implementation RequestBackgroundView

@synthesize activeColor = _activeColor;

@synthesize activeGradient = _activeGradient;

@synthesize inactiveColor = _inactiveColor;

@synthesize inactiveGradient = _inactiveGradient;

- (void)drawRect:(NSRect)dirtyRect
{
    if ( !_activeColor )
    {
        _activeColor = [NSColor colorWithCalibratedWhite:0.7 alpha:1.0];
        _activeGradient = [[NSGradient alloc] initWithColorsAndLocations:
                           _activeColor, 0.0,
                           [NSColor colorWithCalibratedWhite:0.5 alpha:1.0], 1.0,
                           nil];
        _inactiveColor = [NSColor colorWithCalibratedWhite:0.82 alpha:1.0];
        _inactiveGradient = [[NSGradient alloc] initWithColorsAndLocations:
                             _inactiveColor, 0.0,
                             [NSColor colorWithCalibratedWhite:0.75 alpha:1.0], 1.0,
                             nil];
    }
    
    NSRect shadowRect = NSMakeRect( 0, 0, self.bounds.size.width, 45 );
    if ( self.window.isMainWindow )
    {
        [_activeColor set];
        NSRectFill( dirtyRect );
        if ( NSIntersectsRect( shadowRect, dirtyRect ) )
            [_activeGradient drawInRect:shadowRect angle:-90];
    }
    else
    {
        [_inactiveColor set];
        NSRectFill( dirtyRect );
        if ( NSIntersectsRect( shadowRect, dirtyRect ) )
            [_inactiveGradient drawInRect:shadowRect angle:-90];
    }
}

@end
