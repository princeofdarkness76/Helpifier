//
//  AutoRedrawingView.m
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
