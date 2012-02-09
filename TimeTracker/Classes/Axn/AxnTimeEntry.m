//
//  TimeEntry.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/11/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnTimeEntry.h"


@implementation AxnTimeEntry

@synthesize	timeEntryId     = _timeEntryId;
@synthesize	calendarId      = _calendarId;

@synthesize	projectName     = _projectName;
@synthesize	projectAbbrv    = _projectAbbrv;
@synthesize	projectId       = _projectId;

@synthesize	featureName     = _featureName;
@synthesize	featureId       = _featureId;

@synthesize	taskName        = _taskName;
@synthesize	taskId          = _taskId;

@synthesize	notes           = _notes;
@synthesize	entryDate       = _entryDate;

@synthesize	hours           = _hours;
@synthesize	isBillable      = _isBillable;
@synthesize	isLocked        = _isLocked;

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
		
	NSString *text = [NSString stringWithFormat:@"%@ - %2.2f hrs", name, self.hours];
	return text;
}

- (NSString *)labelText
{
    NSString *name = self.projectName;
    if([self.projectAbbrv length] >0){ name = self.projectAbbrv; }
    return name;
}

- (NSString *)subtitleText
{
    return [NSString stringWithFormat:@"%2.2f hrs", self.hours];
}

- (NSString *)description
{
	return [NSString 
            stringWithFormat:@"{\"projectName\":\"%@\",\"featureName\":\"%@\",\"taskName\":\"%@\",\"hours\":%2.2f}", 
			projectName, featureName, taskName, hours];
}

- (void)dealloc 
{
	[_projectName release];
	[_projectAbbrv release];
	[_featureName release];
	[_taskName release];
	[_notes release];
	[_entryDate release];
    [super dealloc];
}


@end
