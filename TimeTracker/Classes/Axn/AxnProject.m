//
//  AxianProject.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnProject.h"

// String prepending to the project name of most/all Axian projects
#define sAxianIncPrepend @"Axian, Inc - "

@implementation AxnProject
@synthesize projectName;
@synthesize projectId;
@synthesize projectFeatures;
@synthesize projectAbbrv;

- (id) init
{
	if(self = [super init])
	{
		// Do initialization
	}
	return self;
}

-(id)initWithDictionary: (NSDictionary *)dic
{
	if(self = [super init])
	{
		self.projectId		= [[dic objectForKey:@"Key"] integerValue];
		self.projectName	= [dic objectForKey:@"Value"];
		
		if((self.projectId == 0)&&(self.projectName == nil))
		{
			self.projectId		= [[dic objectForKey:@"UserProjectId"] integerValue];
			self.projectName	= [dic objectForKey:@"ProjectName"];
			self.projectAbbrv	= [dic objectForKey:@"ProjectAbbreviation"];
		}
		
		if(self.projectAbbrv == nil)
		{
			// TODO: auto generate an abbrv if none is set
			self.projectAbbrv = self.displayName;
		}
	}
	return self;
}

-(NSString *)displayName
{
	if(self.projectName == nil){ return nil; }
	
	if([self.projectName length] > [sAxianIncPrepend length])
	{
		NSString *pre = [self.projectName substringToIndex:[sAxianIncPrepend length]];
		if([pre isEqualToString:sAxianIncPrepend])
		{
			return [self.projectName substringFromIndex:[sAxianIncPrepend length]];
		}
	}
	return self.projectName;
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"%@ (%i)", self.displayName, self.projectId]; 
}

-(void)dealloc
{
	self.projectName        = nil;
	self.projectFeatures    = nil;
    [super dealloc];
}

@end