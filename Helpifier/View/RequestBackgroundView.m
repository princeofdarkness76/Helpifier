//
//  RequestBackgroundView.m
//  Helpifier
//
//  Created by Sean Dougall on 4/13/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
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
