//
//  InboxRequestControlsViewController.m
//  Helpifier
//
//  Created by Sean Dougall on 1/29/11.
//  Copyright 2011 Figure 53. All rights reserved.
//

#import "InboxRequestControlsViewController.h"
#import "RequestViewController.h"


@implementation InboxRequestControlsViewController

@synthesize controlsView = _controlsView;
@synthesize takeItButton = _takeItButton;
@synthesize viewItButton = _viewItButton;
@synthesize viewController = _viewController;

- (IBAction) takeItInHelpifier: (id) sender
{
    [_viewController startTakingIt];
}

- (IBAction) takeItOnWebSite: (id) sender
{
    [_viewController takeIt:sender];
}

- (IBAction) viewRequest: (id) sender
{
    [_viewController viewRequest:sender];
}

@end
