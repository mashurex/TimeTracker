//
//  AxnTodayViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/26/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "AxnTimeEntry.h"
#import "EGORefreshTableHeaderView.h"
#import "AxnTimeEntryViewController.h"
#import "AxnEditTimeEntryViewController.h"

#define sLoginSegue         @"NewEntryLoginModal"
#define sNewEntrySegue      @"NewEntrySegue"
#define sEditEntrySegue     @"EditEntrySegue"

@interface AxnTodayViewController : AxnBaseViewController
<EGORefreshTableHeaderDelegate, UITableViewDelegate, UITableViewDataSource, 
    AxnTimeEntryViewControllerDelegate, AxnEditTimeEntryViewControllerDelegate, MBProgressHUDDelegate>
{
	// AxnTimeEntry collection
	NSMutableArray              *entries;
	UITableView                 *tbvEntries;
	// For pull down refresh
    BOOL                        isReloading;
	EGORefreshTableHeaderView   *refreshHeaderView;
    // Row that was selected for editing or deleting
	NSUInteger                  selectedRow;
	BOOL                        hasLoadedData;
    UIButton                    *btnAddNew;
}

@property (nonatomic, retain)   NSMutableArray              *entries;
@property (nonatomic, assign)   NSUInteger                  selectedRow;
@property (nonatomic, retain)   IBOutlet UITableView        *tbvEntries;
@property (nonatomic, retain)   EGORefreshTableHeaderView   *refreshHeaderView;
@property (nonatomic, assign)   BOOL                        isReloading;
@property (nonatomic, assign)   BOOL                        hasLoadedData;
@property (nonatomic, retain)   IBOutlet UIButton           *btnAddNew;

- (void)doneLoadingTableViewData;
- (void)fetchEntryData;
- (IBAction)showCompletedEntriesHud:(id)sender;
- (IBAction)showFetchingEntriesHud:(id)sender;
@end
