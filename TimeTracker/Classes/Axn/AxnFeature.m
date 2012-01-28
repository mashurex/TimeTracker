//
//  AxianFeature.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnFeature.h"


@implementation AxnFeature

@synthesize featureId       = _featureId;
@synthesize featureName     = _featureName;
@synthesize featureTasks    = _featureTasks;

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
	[_featureName release];
	[_featureTasks release];
    [super dealloc];
}

@end
