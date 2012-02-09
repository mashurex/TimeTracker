//
//  AxnStartupViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/28/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#define sLoginSegue @"StartupLoginSegue"
#define sTabBarSegue @"TabBarSegue"
#define sFetchingProjectsLabelText @"Fetching Projects"

@interface AxnStartupViewController : AxnBaseViewController


- (void)showLoggingInHud;
- (void)hideLoginHudAfterSuccess;

@end
