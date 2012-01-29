//
//  AxnAppDelegate.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSettings.h"

@interface AxnAppDelegate : UIResponder <UIApplicationDelegate>
{
    TTSettings *settings;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) TTSettings *settings;

@end
