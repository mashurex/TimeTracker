//
//  TimeEntry.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/11/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnTimeEntry.h"


@implementation AxnTimeEntry

@synthesize	timeEntryId;
@synthesize	calendarId;

@synthesize	projectName;
@synthesize	projectAbbrv;
@synthesize	projectId;

@synthesize	featureName;
@synthesize	featureId;

@synthesize	taskName;
@synthesize	taskId;

@synthesize	notes;
@synthesize	entryDate;

@synthesize	hours;
@synthesize	isBillable;
@synthesize	isLocked;

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
		self.featureId		= [[dic objectForKey:@"FeatureID"] integerValue];
		self.featureName	=  [dic objectForKey:@"FeatureName"];
		self.isLocked		= [[dic objectForKey:@"Locked"] boolValue];
		self.timeEntryId	= [[dic objectForKey:@"TimeEntryId"] integerValue];
		self.calendarId		= [[dic objectForKey:@"CalendarId"] integerValue];
		self.projectId		= [[dic objectForKey:@"UserProjectId"] integerValue];
		self.projectName	=  [dic objectForKey:@"ProjectName"];
		self.projectAbbrv	=  [dic objectForKey:@"ProjectAbbreviation"];
		self.taskId			= [[dic objectForKey:@"TaskId"] integerValue];
		self.taskName		=  [dic objectForKey:@"TaskName"];
		self.hours			= [[dic objectForKey:@"Hours"] floatValue];
		self.notes			=  [dic objectForKey:@"Notes"];
		self.isBillable		= [[dic objectForKey:@"IsBillable"] boolValue];
	}
	return self;
}

- (NSString*)rowText
{
	NSString *name = self.projectName;
	if([self.projectAbbrv length] > 0){ name = self.projectAbbrv; }
		
	NSString *text = [NSString stringWithFormat:@"%@ - %2.1f hrs", name, self.hours];
	return text;
}

- (NSString *)description
{
	NSString *desc = [[[NSString alloc] 
            initWithFormat:@"{\"projectName\":\"%@\",\"featureName\":\"%@\",\"taskName\":\"%@\",\"hours\":%2.1f}", 
			projectName, featureName, taskName, hours] autorelease];
	return desc;
}

- (void)dealloc 
{
	projectName     = nil;
	projectAbbrv    = nil;
	featureName     = nil;
	taskName        = nil;	
	notes           = nil;
	entryDate       = nil;
    [super dealloc];
}


@end
