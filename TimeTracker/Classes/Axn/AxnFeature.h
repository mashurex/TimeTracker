//
//  AxianFeature.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 10/25/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AxnFeature : NSObject {
	NSString        *featureName;
	NSInteger       featureId;
	NSArray         *featureTasks;
}

@property(copy)     NSString	*featureName;
@property(assign)   NSInteger   featureId;
@property(copy)     NSArray		*featureTasks;

-(id)initWithDictionary:(NSDictionary *)dic;

@end
