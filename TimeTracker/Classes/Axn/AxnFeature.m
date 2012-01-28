//
//  AxianFeature.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnFeature.h"


@implementation AxnFeature

@synthesize featureId;
@synthesize featureName;
@synthesize featureTasks;

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
		self.featureId		= [[dic objectForKey:@"Key"] integerValue];
		self.featureName	= [dic objectForKey:@"Value"];
	}
	return self;
}

-(void)dealloc
{
	self.featureName    = nil;
	self.featureTasks   = nil;
    [super dealloc];
}

@end
