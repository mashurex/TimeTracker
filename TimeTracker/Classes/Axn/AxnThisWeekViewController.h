//
//  AxnThisWeekViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 2/1/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "EGORefreshTableHeaderView.h"

#define sLoginSegue @"ThisWeekLoginModal"

@interface AxnThisWeekViewController : AxnBaseViewController
	<EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
    UITableView                     *tbvEntries;
	BOOL                            isReloading;
	EGORefreshTableHeaderView       *refreshHeaderView;
	NSArray                         *thisWeekDates;
	NSMutableDictionary             *weekEntries;
	NSInteger                       outstandingRequests;
    BOOL                            hasLoadedEntries;
}

@property (nonatomic, retain)	IBOutlet UITableView        *tbvEntries;
@property (nonatomic, retain)	EGORefreshTableHeaderView   *refreshHeaderView;
@property (nonatomic, assign)	BOOL                        isReloading;
@property (nonatomic, assign)   BOOL                        hasLoadedEntries;
@property (nonatomic, copy)		NSArray                     *thisWeekDates;
@property (nonatomic, retain)	NSMutableDictionary         *weekEntries;
@property (nonatomic, assign)	NSInteger                   outstandingRequests;

-(NSString *)convertNSIntegerToDayOfWeek:(NSInteger)day;
-(NSArray *)getCurrentWeekDates;
-(int)getDateArrayPosition: (NSDate *)date;
-(NSString *)convertDateToKeyString: (NSDate *)date;
-(NSArray *)getProjectEntriesForSection:(NSInteger)section;
-(void)fetchEntriesForDate: (NSDate *)date;
-(void)incrementOutstandingRequests;
-(void)decrementOutstandingReuqests;
-(void)refreshAllDates;
-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;
- (IBAction)showFetchingEntriesHud:(id)sender;
- (IBAction)showCompletedEntriesHud:(id)sender;

@end
