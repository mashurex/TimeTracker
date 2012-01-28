//
//  AxianTask.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnTask.h"


@implementation AxnTask

@synthesize taskId;
@synthesize taskName;
@synthesize budgetedHours;
@synthesize projectId;
@synthesize phaseId;
@synthesize state;
@synthesize hoursLeft;
@synthesize featureId;

- (id)init
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
		self.taskId			= [[dic objectForKey:@"TaskId"] intValue];
		self.taskName		= [dic objectForKey:@"task"];
		self.budgetedHours	= [[dic objectForKey:@"BudgetedHours"] floatValue];
		self.projectId		= [[dic objectForKey:@"ProjectId"] integerValue];
		self.phaseId		= [[dic objectForKey:@"PhaseId"] integerValue];
		self.state			= [[dic objectForKey:@"State"] integerValue];
		self.hoursLeft		= [[dic objectForKey:@"HoursLeft"] floatValue];
		self.featureId		= [[dic objectForKey:@"FeatureId"] integerValue];
	}
	return self;
}

-(void)dealloc
{
	self.taskName = nil;
    [super dealloc];
}

@end
