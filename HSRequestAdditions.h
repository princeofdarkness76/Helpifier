//
//  HSRequestAdditions.h
//  Helpifier
//
//  Created by Sean Dougall on 9/29/10.
//  Copyright 2010 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <HelpSpot/HelpSpot.h>

@interface HSRequest (HelpificatorAdditions)

@property (assign) BOOL hasUnseenHistory;
@property (readonly) NSUInteger numberOfHistoryItems;

@end
