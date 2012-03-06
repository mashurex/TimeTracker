//
//  AxnTimeTrackerClient.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 2/23/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

/***********************************
 * Not used yet
 * Will be used as a Client type API to handle
 * all iOS TimeTracker HTTP requests
 ***********************************/

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

#define sUsernameDicKey         @"userName"
#define sPasswordDicKey         @"password"
#define sDataDicKey             @"d"
#define sNullDataResponse       @"{\"d\":null}"

#define sBaseTimeTrackerUrl @"https://ttstage.axian.com"
#define sAuthenticateUrl    sBaseTimeTrackerUrl "/webservices/login.asmx/Authenticate"
#define sGetProjectsUrl     sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetProjects"
#define sGetFeaturesUrl     sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetFeatures"
#define sGetTasksUrl        sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetTasks"
#define sGetEntriesUrl      sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/GetTimeEntriesByDate"
#define sAddTimeUrl			sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/AddTime"
#define sEditTimeUrl        sBaseTimeTrackerUrl "/webservices/timeentryservice.asmx/UpdateTime"

#define sUTF8               @"utf-8"
#define sContentTypeJson    @"application/json"
#define sRequestPost        @"POST"

#define kRequest_AuthenticateTag		(int)10
#define kRequest_FetchProjectsTag		(int)20
#define kRequest_FetchEntriesTag		(int)30
#define kRequest_RemoveEntryTag			(int)40
#define kRequest_ValidateAuthTag		(int)50
#define kRequest_SaveNewEntryTag        (int)60
#define kRequest_SaveEditEntryTag       (int)61

#define kDefaultRequestTimeout          (int)15

#define sAuthenticationNeeded @"Authentication needed"

@protocol AxnTimeTrackerDelegate
- (void) authenticationRequestFailed:(ASIHTTPRequest *)request;
@end

@interface AxnTimeTrackerClient : NSObject <ASIHTTPRequestDelegate>
{
    id <AxnTimeTrackerDelegate> delegate;
}

@property(nonatomic, assign) id<AxnTimeTrackerDelegate> delegate; 

- (NSString *)todayString;
- (NSString *)convertDateToRequestString: (NSDate *)date;
- (void)requestFailed:(ASIHTTPRequest *)request;
- (ASIHTTPRequest *)createPostRequest:(NSURL *)url withParameters:(NSDictionary *)params;
- (ASIHTTPRequest *)createLoginRequest:(NSString *)username withPassword:(NSString *)password; 
- (ASIHTTPRequest *)createFetchProjectsRequest;
- (NSArray *)fetchFeatures:(NSInteger)projectId;
- (NSArray *)fetchTasks:(NSInteger)projectId forFeature:(NSInteger)featureId;
- (NSDictionary *)getJsonDataFromResponseString:(NSString *)responseString error:(NSError **)error;
- (BOOL)requestFailedOnAuth:(ASIHTTPRequest *)request;

@end
