//
//  AxnLoginViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/25/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"

@interface AxnLoginViewController : AxnBaseViewController
{
    UIButton    *btnLogin;
	UITextField *txtUsername;
	UITextField *txtPassword;
}

@property(nonatomic, retain) IBOutlet UIButton      *btnLogin;
@property(nonatomic, retain) IBOutlet UITextField   *txtUsername;
@property(nonatomic, retain) IBOutlet UITextField   *txtPassword;

-(IBAction)buttonLogin_Pressed;
-(IBAction)resignAllResponders:(id)sender;
-(void)setPasswordFocus;

@end
