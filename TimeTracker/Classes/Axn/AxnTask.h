//
//  AxianTask.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AxnTask : NSObject {
	NSInteger	taskId;
	NSString	*taskName;
	float		budgetedHours;
	NSInteger	projectId;
	NSInteger	phaseId;
	NSInteger	state;
	float		hoursLeft;
	NSInteger	featureId;
}

@property(assign)   NSInteger taskId;
@property(copy)     NSString  *taskName;
@property(assign)   float     budgetedHours;
@property(assign)   NSInteger projectId;
@property(assign)   NSInteger phaseId;
@property(assign)   NSInteger state;
@property(assign)   float     hoursLeft;
@property(assign)   NSInteger featureId;

- (id)initWithDictionary:(NSDictionary *)dic;

@end
