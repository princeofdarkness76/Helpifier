//
//  RequestUpdateNoticeView.h
//  Helpifier
//
//  Created by Sean Dougall on 4/22/12.
//  Copyright (c) 2012 Figure 53. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class RequestUpdateNoticeView;

@protocol RequestUpdateNoticeViewDelegate

- (void)requestUpdateNoticeViewClicked:(RequestUpdateNoticeView *)sender;

@end

#pragma mark -

@interface RequestUpdateNoticeView : NSView

@property (weak) IBOutlet id <RequestUpdateNoticeViewDelegate> delegate;

@end
