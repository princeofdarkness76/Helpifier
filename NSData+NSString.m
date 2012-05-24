//
//  NSString+NSData.m
//  Helpifier
//
//  Created by Sean Dougall on 5/28/10.
//
//	Copyright (c) 2010-2011 Figure 53 LLC, http://figure53.com
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

#import "NSData+NSString.h"


@implementation NSData (NSStringConversion)

- (NSString *) UTF8String
{
	char *nullTerm = malloc(sizeof(char));
	nullTerm[0] = 0x0;
	
	NSMutableData *newData = [self mutableCopy];
	if (((char *)[newData bytes])[[newData length] - 1] != 0x0)
		[newData appendBytes:nullTerm length:1];
	
	free(nullTerm);
	
	NSString *result = [NSString stringWithCString:[newData bytes] encoding:NSUTF8StringEncoding];
	[newData release];
	
	return result;
}

@end
