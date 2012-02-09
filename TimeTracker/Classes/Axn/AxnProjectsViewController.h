//
//  AxnProjectsViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/24/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface AxnProjectsViewController : AxnBaseViewController
<EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource>
{
	NSArray                     *projects;
	UITableView                 *tbvProjects;
	EGORefreshTableHeaderView   *refreshHeaderView;
	BOOL                        isReloading;
}

@property (nonatomic, retain) NSArray                   *projects;
@property (nonatomic, retain) IBOutlet UITableView      *tbvProjects;
@property (nonatomic, retain) EGORefreshTableHeaderView *refreshHeaderView;
@property (nonatomic, assign) BOOL                      isReloading;

-(void)reloadTableViewDataSource;
-(void)doneLoadingTableViewData;
-(void)fetchEntryData;
-(IBAction)showCompletedEntriesHud:(id)sender;
-(IBAction)showFetchingEntriesHud:(id)sender;

@end
