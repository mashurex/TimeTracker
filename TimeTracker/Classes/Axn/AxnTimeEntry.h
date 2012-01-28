//
//  TimeEntry.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/11/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import <Foundation/NSObject.h>

@interface AxnTimeEntry : NSObject 
{
	NSInteger	timeEntryId;
	NSInteger	calendarId;
	
	NSString	*projectName;
	NSString	*projectAbbrv;
	NSInteger	projectId;
	
	NSString	*featureName;
	NSInteger	featureId;
	
	NSString	*taskName;
	NSInteger	taskId;
	
	NSString	*notes;
	NSDate		*entryDate;
	
	float		hours;
	BOOL		isBillable;
	BOOL		isLocked;
}

@property(nonatomic, assign)	NSInteger	timeEntryId;
@property(nonatomic, assign)	NSInteger	calendarId;
@property(nonatomic, copy)		NSString*	projectName;
@property(nonatomic, copy)		NSString*	projectAbbrv;
@property(nonatomic, assign)	NSInteger	projectId;
@property(nonatomic, copy)		NSString*	featureName;
@property(nonatomic, assign)	NSInteger	featureId;
@property(nonatomic, copy)		NSString*	taskName;
@property(nonatomic, assign)	NSInteger	taskId;
@property(nonatomic, copy)		NSDate*		entryDate;
@property(nonatomic, copy)		NSString*	notes;
@property(nonatomic, assign)	float		hours;
@property(nonatomic, assign)	BOOL		isBillable;
@property(nonatomic, assign)	BOOL		isLocked;

- (id)initWithDictionary: (NSDictionary *)dic;
- (NSString *)rowText;
- (NSString *)labelText;
- (NSString *)subtitleText;

@end
