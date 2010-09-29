//
//  HSRequestAdditions.m
//  Helpifier
//
//  Created by Sean Dougall on 9/29/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import "HSRequestAdditions.h"


@implementation HSRequest (HelpificatorAdditions)

- (BOOL) hasUnseenHistory 
{
	return [[content objectForKey:@"hasUnseenHistory"] boolValue];
}

- (void) setHasUnseenHistory: (BOOL) newValue
{
	[content setObject:[NSNumber numberWithBool:newValue] forKey:@"hasUnseenHistory"];
}

@end
