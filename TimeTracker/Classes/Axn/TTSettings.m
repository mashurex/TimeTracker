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

@synthesize username;
@synthesize password;
@synthesize timeTrackerUrl;
@synthesize doReminder;
@synthesize isRecentlyAuthed;
@synthesize axianProjects;

- (id) init
{
	if(self = [super init])
	{
		// Do initialization
	}
	return self;
}

- (AxnProject *)projectWithId:(NSInteger)projectId
{
	for(AxnProject *p in axianProjects)
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

- (void)readSettings
{
	KeychainItemWrapper *keyChain = [[KeychainItemWrapper alloc] initWithIdentifier:sKeyChainIdentifier accessGroup:nil];
	[self setUsername:[keyChain objectForKey:(id)kSecAttrAccount]];
	[self setPassword:[keyChain objectForKey:(id)kSecValueData]];
	[keyChain release];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[self setDoReminder:[[defaults objectForKey:@"doReminder"] boolValue]];
}

- (void)saveSettings
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];		
	[defaults setBool:self.doReminder forKey:@"doReminder"];
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
}

-(void)dealloc
{
	self.username = nil;
	self.password = nil;
	self.timeTrackerUrl = nil;
	self.axianProjects = nil;	
	[super dealloc];
}

@end
