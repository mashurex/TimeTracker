//
//  AxnTodayViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/26/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnTodayViewController.h"

@implementation AxnTodayViewController

@synthesize entries                 = _entries;
@synthesize tbvEntries              = _tbvEntries;
@synthesize refreshHeaderView       = _refreshHeaderView;
@synthesize isReloading             = _isReloading;
@synthesize selectedRow             = _selectedRow;
@synthesize hasLoadedData           = _hasLoadedData;
@synthesize btnAddNew               = _btnAddNew;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    // Hide navigation bar before the view appears
    // We want the navigation bar to show on subsequent 'children' views, but it
    // clutters up this view that we'll be spending most the time in
    [self.navigationController setNavigationBarHidden:YES];
    
    if(self.comingFromLogin)
    {
        [self fetchEntryData];
        self.comingFromLogin = NO;
    }
    else if(!self.hasLoadedData)
    {
        [self fetchEntryData];
    }
    
    // Unselect the selected row if any
    NSIndexPath* selection = [self.tbvEntries indexPathForSelectedRow];
    if (selection)
    {
        [self.tbvEntries deselectRowAtIndexPath:selection animated:YES];
    }
    
    [super viewWillAppear:animated];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    [backButton release];
    
    
    // Create a save button and put it in the naviation bar
    
    UIImage *btnImg = [[UIImage imageNamed:@"nav-btn.png"] 
                       resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
    UIImage *btnCancelImg = [[UIImage imageNamed:@"cancel-nav-btn.png"]
                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
    
    [[UIBarButtonItem appearance] setBackgroundImage:btnImg forState:UIControlStateNormal 
                                          barMetrics:UIBarMetricsDefault];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:btnCancelImg 
                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    
    

    // Set the table view background to our pattern
    // self.tbvEntries.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bground.png"]];
    
    // Set Add New button color to red
    // [self.btnAddNew setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    
    self.entries = [[NSMutableArray alloc] initWithCapacity:1];
    self.hasLoadedData = NO;
    
    if(!self.refreshHeaderView)
    {
        EGORefreshTableHeaderView *rView = [[EGORefreshTableHeaderView alloc] 
                                  initWithFrame:CGRectMake(0.0f, 0.0f - self.tbvEntries.bounds.size.height, 
                                            self.view.frame.size.width, self.tbvEntries.bounds.size.height)];
		rView.delegate = self;
		[self.tbvEntries addSubview:rView];
        self.refreshHeaderView = rView;
    }
    
    // Update the last update date
    [self.refreshHeaderView refreshLastUpdatedDate];
}

- (void)viewDidAppear:(BOOL)animated
{
    if(!self.hasLoadedData)
    {
        [self fetchEntryData];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.entries = nil;
    self.tbvEntries = nil;
    self.refreshHeaderView = nil;
    self.btnAddNew = nil;
}

- (void)dealloc
{
    [_entries release];
    [_tbvEntries release];
    [_refreshHeaderView release];
    [_btnAddNew release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated 
{
	[navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)hudWasHidden:(MBProgressHUD *)hud 
{
    // Remove HUD from screen when the HUD was hidden
    [self.hud removeFromSuperview];
    [self.hud release];
	self.hud = nil;
}


- (IBAction)showFetchingEntriesHud:(id)sender
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];

    self.hud.delegate = self;
    self.hud.labelText = @"Loading...";
    self.hud.detailsLabelText = @"Fetching Entries";
 
    [self.hud show:YES];
}

- (IBAction)showCompletedEntriesHud:(id)sender
{
    self.hud.customView = [[[UIImageView alloc] 
                            initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] 
                           autorelease];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = @"Success";
    self.hud.detailsLabelText = @"";
    [self.hud hide:YES afterDelay:0.75];
}

#pragma mark - UI Actions/Methods

// Segue to the new entry form
- (void)segueToNewEntryForm
{
    [self performSegueWithIdentifier:sNewEntrySegue sender:self];
}

- (IBAction)buttonAddNewEntry_Pressed
{
    [self segueToNewEntryForm];
}

#pragma mark - DataSource details

- (void)fetchEntryData
{	
    // Don't fire off multiple requests
    if(self.isReloading){ return; }
    
    self.isReloading = YES;
    
    [self showFetchingEntriesHud:nil];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
											  [self todayString], @"date", nil];

	NSURL *url = [NSURL URLWithString: sGetEntriesUrl];
    ASIHTTPRequest *request = [self createPostRequest:url withParameters:params];
    [request setDelegate: self];
	[request setTag: kRequest_FetchEntriesTag];
	[request startAsynchronous];
}

#pragma mark - HTTP handlers

- (void)processEntryRequestResponse:(NSArray *)jsonData
{
	NSMutableArray *entryArray = [[NSMutableArray alloc] init];

	for(int i = 0; i < [jsonData count]; i++)
	{
		NSDictionary *dicEntryData = [jsonData objectAtIndex:i];
		AxnTimeEntry *entry = [[AxnTimeEntry alloc] initWithDictionary:dicEntryData];
		[entryArray addObject:entry];
		[entry release];
	}
	
	self.entries = entryArray;
    
	// Refresh the table view
    [self showCompletedEntriesHud:nil];
	[self.tbvEntries reloadData];
	[self doneLoadingTableViewData];
    
    // Cleanup
	[entryArray release];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	// Error object for containing parsing error
	NSError *error = nil;    
    // NSLog(@"Response finished: %@", [request responseString]);
    NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
	if(!jsonData)
	{
        [self.hud hide:YES];
        if(error != nil)
        {
            [self showAlert:@"Error" withMessage:[error localizedDescription]];
        }
        else
        {
            [self showAlert:@"Error" withMessage:@"Unknown error occurred."];
        }
	}
	else 
	{		
		if(request.tag == kRequest_FetchEntriesTag)
		{            
            self.hasLoadedData = YES;
			[self processEntryRequestResponse: [jsonData objectForKey:sTimeTrackerDataDicKey]];
		}
		else if(request.tag == kRequest_RemoveEntryTag)
		{
			// [self processRemoveEntryResponse: [jsonData objectForKey:sTimeTrackerDataDicKey]];
		}
	}
    [self.hud hide:YES];
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self doneLoadingTableViewData];
    [self.hud hide:YES];
    
	[super requestFailed:request];	
	
    if([self requestFailedOnAuth:request])
    {
        [self showLoginForm:sLoginSegue sender:self];
    }
    else
    {
        NSString *errorMsg = @"Request error occurred.";
        if(request.tag == kRequest_FetchEntriesTag)
        {
            errorMsg = @"Could not fetch entries.";
        }
        
        [self showAlert:@"Error" withMessage:errorMsg];
        [errorMsg release];
    }
}

#pragma mark - UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{	
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - EGORefreshTableHeaderView 

- (void)reloadTableViewDataSource
{
	[self fetchEntryData];
}

- (void)doneLoadingTableViewData
{
    self.isReloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbvEntries];
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView *)view
{
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

// Returns YES if data source model is reloading
- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView *)view
{
	return self.isReloading; 
}

// Returns date data source was last changed
- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView *)view
{
	return [NSDate date]; 
}

#pragma mark - Table View Data Source Methods

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self.tbvEntries reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.entries count];
}

/**
 * Return section titles
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0){ return @"Today's Entries"; }
	return nil;
}

/**
 * Return UITableViewCell at index (used for populating)
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *SimpleTableIdentifier = @"TodayCell";

	// Reuse a cell if possible
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	
    // Instantiate a new cell if we couldn't get a reusable one
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleSubtitle 
				 reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
	
	AxnTimeEntry *entry = [self.entries objectAtIndex:[indexPath row]];
	cell.textLabel.text = [entry labelText];
    // Set the label text to white
    // cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.text = [entry subtitleText];
	
	return cell;
}

#pragma mark -
#pragma mark Table Delegate Methods

/**
 * Return the indentation level for the row
 * Currently set to always return 0, possible to implement
 * some type of fancy indentation levels
 */
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 0;
}

/**
 * Return the selected indexPath
 */
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    return indexPath;
}


- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath 
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

/**
 * Act on the selected cell
 */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSUInteger row = [indexPath row];
    
	// AxnTimeEntry *entry = [self.entries objectAtIndex:row];
	self.selectedRow = row;
	
    /* TODO: Pop up editor
	self.detailVC = [[TodayEntryDetailViewController alloc] initWithNibName:@"TodayEntryDetail" bundle:nil];
	self.detailVC.title = entry.projectAbbrv;
	self.detailVC.timeEntry = entry;
	
	NSLog(@"DailyViewController: Sending detailVC entry: %@", entry);
//	self.controllerComingFrom = sComingFromEditEntryViewController;
	[self.navigationController pushViewController:detailVC animated:YES];
    
	[tableView deselectRowAtIndexPath:indexPath animated:YES];
     */
//    NSLog(@"Selected entry: %@", [entry rowText]);
    [self performSegueWithIdentifier:sEditEntrySegue sender:self];
}

#pragma mark - Segue and Delegate Methods

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:sNewEntrySegue])
    {
        // Set the new time entry view controller as our destination
        AxnTimeEntryViewController *vc = (AxnTimeEntryViewController *)[segue destinationViewController];
        // Identify this controller as the delegate (to recieve the saved time entry back)
        [vc setDelegate:self];
    }
    else if([[segue identifier] isEqualToString:sEditEntrySegue])
    {
        AxnEditTimeEntryViewController *vc = (AxnEditTimeEntryViewController *)[segue destinationViewController];
        [vc setDelegate:self];
        [vc setTimeEntry:[self.entries objectAtIndex:self.selectedRow]];
    }
}

- (void)addSavedTimeEntry:(AxnTimeEntry *)entry
{
    [self.entries addObject:entry];
    [self.tbvEntries reloadData];
}

- (void)editTimeEntry:(AxnTimeEntry *)entry
{
    [self.entries replaceObjectAtIndex:self.selectedRow withObject:entry];
    [self.tbvEntries reloadData];
}

@end
