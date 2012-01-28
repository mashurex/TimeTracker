//
//  AxianProject.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AxnProject : NSObject 
{
	NSString	*projectName;
	NSInteger	projectId;
	NSArray		*projectFeatures;
	NSString	*projectAbbrv;
}

@property(nonatomic, copy)		NSString	*projectName;
@property(nonatomic, copy)		NSArray		*projectFeatures;
@property(nonatomic, assign)	NSInteger	projectId;
@property(nonatomic, copy)		NSString	*projectAbbrv;

- (NSString *)displayName;
- (id)initWithDictionary: (NSDictionary *)dic;

@end
