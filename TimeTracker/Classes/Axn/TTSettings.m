//
//  TTSettings.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 11/1/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "TTSettings.h"
#import "AxnProject.h"
#import "AxnFeature.h"
#import "AxnTask.h"
#import "KeychainItemWrapper.h"

@implementation TTSettings

@synthesize username            = _username;
@synthesize password            = _password;
@synthesize timeTrackerUrl      = _timeTrackerUrl;
@synthesize doReminder          = _doReminder;
@synthesize hasLoggedIn         = _hasLoggedIn;
@synthesize axianProjects       = _axianProjects;
@synthesize reminderDate        = _reminderDate;

- (AxnProject *)projectWithId:(NSInteger)projectId
{
	for(AxnProject *p in self.axianProjects)
	{
		if(p.projectId == projectId)
		{
			return p;
		}
	}
	return nil;
}

- (AxnFeature *)featureForProject:(NSInteger)projectId withId:(NSInteger)featureId
{
	AxnProject *p = [self projectWithId:projectId];
	
	if(p == nil){ return nil; }
	
	for(AxnFeature *f in p.projectFeatures)
	{
		if(f.featureId == featureId)
		{
			return f;
		}
	}
	
	return nil;
}

- (AxnTask *)taskForProject:(NSInteger)projectId forFeature:(NSInteger)featureId withId:(NSInteger)taskId
{
	AxnFeature *f = [self featureForProject:projectId withId:featureId];
	
	if(f == nil){ return nil; }
	
	for(AxnTask *t in f.featureTasks)
	{
		if(t.taskId == taskId)
		{
			return t;
		}
	}
	
	return nil;
}

- (BOOL)hasCredentials
{
	if(self.username == nil){ return NO; }
	else if(self.password == nil){ return NO; }
	else if([self.username length] < 1){ return NO; }
	else if([self.password length] < 1){ return NO; }
	
	return YES;
}

- (NSString *)getReminderTimeAsString
{
    if(self.reminderDate == nil){ return nil; }
    NSDateFormatter *frmt = [[[NSDateFormatter alloc] init] autorelease];
    frmt.dateFormat = @"hh:mm a";
    return [frmt stringFromDate:self.reminderDate];
}

- (NSString *)getReminderDateAsString
{
    if(self.reminderDate == nil){ return nil; }
    NSDateFormatter *frmt = [[[NSDateFormatter alloc] init] autorelease];
    frmt.dateFormat = sReminderDateFormat;
    return [frmt stringFromDate:self.reminderDate];
}

- (void)readSettings
{
	KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:sKeyChainIdentifier accessGroup:nil];
	self.username = [keyChain objectForKey:(id)kSecAttrAccount];
	self.password = [keyChain objectForKey:(id)kSecValueData];
	[keyChain release];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	self.doReminder = [[defaults objectForKey:@"doReminder"] boolValue];
    NSString *dateString = [defaults objectForKey:@"reminderDate"];
    if((dateString != nil)&&([dateString length] > 0))
    {
        NSDateFormatter *frmt = [[NSDateFormatter alloc] init];
        frmt.dateFormat = sReminderDateFormat;
        self.reminderDate = [frmt dateFromString:dateString];
        [frmt release];
    }
}

- (void)saveSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];		
	[defaults setBool:self.doReminder forKey:@"doReminder"];
    [defaults setValue:[self getReminderDateAsString] forKey:@"reminderDate"];
	[defaults synchronize];
	
	KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:sKeyChainIdentifier accessGroup:nil];
	[keyChain setObject:self.username forKey:(id)kSecAttrAccount];
	[keyChain setObject:self.password forKey:(id)kSecValueData];
	[keyChain release];
}

- (void)clearSettings
{
	NSString *appDomain = [[NSBundle mainBundle] bundleIdentifier];
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults removePersistentDomainForName:appDomain];
	
	KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:sKeyChainIdentifier accessGroup:nil];
	[keyChain resetKeychainItem];
	[keyChain release];
	
	[self setUsername:nil];
	[self setPassword:nil];
    [self setDoReminder:NO];
    [self setReminderDate:nil];
    [self setAxianProjects:nil];
    [self setHasLoggedIn:NO];
}

- (id) init
{
	if(self = [super init])
	{
		// Do initialization
	}
	return self;
}

-(void)dealloc
{	
    [_username release];
    [_password release];
    [_timeTrackerUrl release];
    [_axianProjects release];
	[super dealloc];
}

@end
