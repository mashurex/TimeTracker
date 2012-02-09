//
//  AxnViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/22/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSettings.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

#define sUsernameDicKey     @"userName"
#define sPasswordDicKey     @"password"
#define sTimeTrackerDataDicKey  @"d"

#define sBaseTimeTrackerUrl @"https://ttstage.axian.com"
#define sAuthenticateUrl    sBaseTimeTrackerUrl "/webservices/login.asmx/Authenticate"
#define sGetProjectsUrl     sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetProjects"
#define sGetFeaturesUrl     sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetFeatures"
#define sGetTasksUrl        sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetTasks"
#define sGetEntriesUrl      sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetTimeEntriesByDate"
#define sAddTimeUrl			sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/AddTime"
#define sEditTimeUrl        sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/UpdateTime"

#define kRequest_AuthenticateTag		(int)10
#define kRequest_FetchProjectsTag		(int)20
#define kRequest_FetchEntriesTag		(int)30
#define kRequest_RemoveEntryTag			(int)40
#define kRequest_ValidateAuthTag		(int)50
#define kRequest_SaveNewEntryTag        (int)60
#define kRequest_SaveEditEntryTag       (int)61

#define kDefaultRequestTimeout          (int)15

#define sAuthenticationNeeded @"Authentication needed"

#define sHudMsg_LoginError @"Error logging in!"
#define sHudMsg_ProjectsError @"Couldn't fetch projects!"

@interface AxnBaseViewController : UIViewController
<ASIHTTPRequestDelegate, MBProgressHUDDelegate>
{
    TTSettings      *ttSettings;
    BOOL            comingFromLogin;
    MBProgressHUD   *hud;
}

@property (nonatomic, retain) TTSettings *ttSettings;
@property (nonatomic, assign) BOOL comingFromLogin;
@property (nonatomic, retain) MBProgressHUD *hud;

- (IBAction)textFieldDoneEditing:(id)sender;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (NSString *)todayString;
- (ASIHTTPRequest *)createPostRequest:(NSURL *)url withParameters:(NSDictionary *)params;
- (ASIHTTPRequest *)createLoginRequest:(NSString *)username withPassword:(NSString *)password; 
- (ASIHTTPRequest *)createFetchProjectsRequest;
- (NSArray *)fetchFeatures:(NSInteger)projectId;
- (NSArray *)fetchTasks:(NSInteger)projectId forFeature:(NSInteger)featureId;
- (NSString *)convertDateToRequestString: (NSDate *)date;
- (NSDictionary *)getJsonDataFromResponseString:(NSString *)responseString error:(NSError **)error;
- (void)showHud:(UIView *)view withLabel:(NSString *)text;
- (void)showSuccessfullyCompletedHud:(NSString *)labelText;
- (void)hideHud:(NSTimeInterval)delay;
- (BOOL)requestFailedOnAuth:(ASIHTTPRequest *)request;
- (void)showLoginForm:(NSString *)segueIdentifier sender:(id)sender;
- (void)showAlert:(NSString *)title withMessage:(NSString *)message;
@end
