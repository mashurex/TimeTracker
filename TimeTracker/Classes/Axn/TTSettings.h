//
//  TTSettings.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 11/1/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AxnProject.h"
#import "AxnFeature.h"
#import	"AxnTask.h"
#define sKeyChainIdentifier @"TimeTrackerApp"

@interface TTSettings : NSObject 
{
	NSString *username;
	NSString *password;
	NSString *timeTrackerUrl;
	NSString *authToken;
	
	BOOL doReminder;
	BOOL isRecentlyAuthed;

	NSArray *axianProjects;
}

@property(nonatomic, copy)      NSString    *username;
@property(nonatomic, copy)      NSString    *password;
@property(nonatomic, copy)      NSString    *timeTrackerUrl;
@property(nonatomic, assign)    BOOL        hasLoggedIn;
@property(nonatomic, assign)    BOOL        doReminder;
@property(nonatomic, copy)      NSArray     *axianProjects;

- (BOOL)hasCredentials;
- (AxnProject *)projectWithId:(NSInteger)projectId;
- (AxnFeature *)featureForProject:(NSInteger)projectId withId:(NSInteger)featureId;
- (AxnTask *)taskForProject:(NSInteger)projectId forFeature:(NSInteger)featureId withId:(NSInteger)taskId;
- (void)saveSettings;
- (void)readSettings;
- (void)clearSettings;

@end
