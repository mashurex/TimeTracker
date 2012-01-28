//
//  AxnViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/22/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSettings.h"

#define sUsernameDicKey     @"userName"
#define sPasswordDicKey     @"password"

#define sBaseTimeTrackerUrl @"https://ttstage.axian.com"
#define sAuthenticateUrl    sBaseTimeTrackerUrl + "/webservices/login.asmx/Authenticate"
#define sGetProjectsUrl     sBaseTimeTrackerUrl + "/webservices/timeentryservice.asmx/GetProjects"
#define sGetFeaturesUrl     sBaseTimeTrackerUrl + "/webservices/timeentryservice.asmx/GetFeatures"
#define sGetTasksUrl        sBaseTimeTrackerUrl + "/webservices/timeentryservice.asmx/GetTasks"

#define kRequest_AuthenticateTag		(int)10
#define kRequest_FetchProjectsTag		(int)20
#define kRequest_FetchEntriesTag		(int)30
#define kRequest_RemoveEntryTag			(int)40
#define kRequest_ValidateAuthTag		(int)50

#define kDefaultRequestTimeout          (int)15

#define sAuthenticationNeeded @"Authentication needed"

@interface AxnBaseViewController : UIViewController
{
    TTSettings *ttSettings;
}

@property (nonatomic, retain) TTSettings *ttSettings;


-(IBAction)textFieldDoneEditing:(id)sender;
-(TTSettings *) timeTrackerSettings;
-(NSString *)convertDateToRequestString: (NSDate *)date;
-(NSString *)todayString;

@end
