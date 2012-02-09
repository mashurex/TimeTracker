//
//  AxnProjectsViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/24/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnProjectsViewController.h"

@implementation AxnProjectsViewController

@synthesize projects            = _projects;
@synthesize tbvProjects         = _tbvProjects;
@synthesize refreshHeaderView   = _refreshHeaderView;
@synthesize isReloading         = _isReloading;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
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

- (void)hudWasHidden:(MBProgressHUD *)hud 
{
    // Remove HUD from screen when the HUD was hidden
    [self.hud removeFromSuperview];
    [self.hud release];
	self.hud = nil;
}


- (IBAction)showFetchingEntriesHud:(id)sender
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:self.hud];
    
    self.hud.delegate = self;
    self.hud.labelText = @"Loading...";
    self.hud.detailsLabelText = @"Fetching Projects";
    
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

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    if(refreshHeaderView == nil)
	{
		EGORefreshTableHeaderView *rView = [[EGORefreshTableHeaderView alloc] 
                                           initWithFrame:CGRectMake(0.0f, 0.0f - self.tbvProjects.bounds.size.height, 
                                                self.view.frame.size.width, self.tbvProjects.bounds.size.height)];
		rView.delegate = self;
		[self.tbvProjects addSubview:rView];
		self.refreshHeaderView = rView;
		[rView release];
		// Update the last update date
		[self.refreshHeaderView refreshLastUpdatedDate];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
    if((self.ttSettings.axianProjects == nil)||([self.ttSettings.axianProjects count] < 1))
	{
		[self fetchEntryData];
	}
	else 
    {
		self.projects = self.ttSettings.axianProjects;
		[self.tbvProjects reloadData];
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.projects = nil;
    self.tbvProjects = nil;
    self.refreshHeaderView = nil;
}

- (void)dealloc
{
    [_projects release];
    [_tbvProjects release];
    [_refreshHeaderView release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - EGORefreshTableHeaderView 

- (void)reloadTableViewDataSource
{
	[self fetchEntryData];
}

- (void)doneLoadingTableViewData
{
    self.isReloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbvProjects];
}

#pragma mark - DataSource Details

- (void)fetchEntryData
{		
    if(self.isReloading){ return; }
    [self showFetchingEntriesHud:nil];
    self.isReloading = YES;
    
	NSString *today = [self todayString];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:today, @"date", nil];
    
	// Create an asynchronous form post to test the login
	NSURL *url = [NSURL URLWithString:sGetProjectsUrl];
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:params];
	[request setDelegate:self];
	[request setTag:kRequest_FetchProjectsTag];
	// Send it the request off to the interwebs asynchronously
	// preventing UI blocking
	[request startAsynchronous];
}

/**
 * Validation form post request finished
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{	
	// Error object for string to json process
	NSError *error = nil;
    NSDictionary *jsonData = [super getJsonDataFromResponseString:[request responseString] error:&error];
    
	if(jsonData == nil)
	{
        [self.hud hide:YES];
		NSLog(@"No json response %@.", [request responseString]);
	}
	else 
	{
		NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
		// Get all the entry collections
		NSArray *entries = [jsonData objectForKey:sTimeTrackerDataDicKey];
		// Iterate through them and initialize each TimeEntry object
        
		int i;
		for(i = 0; i < [entries count]; i++)
		{
			NSDictionary *entryDic = [entries objectAtIndex:i];
			AxnProject *entry = [[AxnProject alloc] initWithDictionary:entryDic];
			NSArray *features = [self fetchFeatures:entry.projectId];
			if(features != nil)
			{
				int j;
				for(j = 0; j < [features count]; j++)
				{
					AxnFeature *f = [features objectAtIndex:j];
					f.featureTasks = [self fetchTasks:entry.projectId forFeature:f.featureId];
				}
				entry.projectFeatures = features;
				[projectsArray addObject:entry];
				[entry release];		
			}
			else 
			{
				NSLog(@"No features to fetch tasks for...");
			}
		}
		
		self.ttSettings.axianProjects = (NSArray *)projectsArray;
		self.projects = (NSArray *)projectsArray;
		[projectsArray release];
	}
    
    [self showCompletedEntriesHud:nil];
    [self.tbvProjects reloadData];
	[self doneLoadingTableViewData];
}

/**
 * Validation form post request failed
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    [self.hud hide:YES];
    [self doneLoadingTableViewData];
	[super requestFailed:request];
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{		
	[self.refreshHeaderView egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{	
	[self.refreshHeaderView egoRefreshScrollViewDidEndDragging:scrollView];	
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view
{
	[self reloadTableViewDataSource];
	[self performSelector:@selector(doneLoadingTableViewData) withObject:nil afterDelay:3.0];
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view
{
	return self.isReloading;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view
{
	return [NSDate date]; 
}


#pragma mark - Table View Data Source Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.projects count];
}

/**
 * Return section titles
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if(section == 0)
	{
		return @"Active Projects";
	}
	else 
    {
		return @"Unknown";
	}
}

/**
 * Return UITableViewCell at index (used for populating)
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *SimpleTableIdentifier = @"ProjectsCell";
	// Reuse a cell that has already been drawn if possible
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	// Otherwise instantiate a new cell
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITableViewCellStyleDefault 
				 reuseIdentifier:SimpleTableIdentifier] autorelease];
	}
	
	NSUInteger row = [indexPath row];
	AxnProject *e = [self.projects objectAtIndex:row];
	cell.textLabel.text = [e displayName];
	
	return cell;
} 


#pragma mark - Table Delegate Methods

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	return 0;
}

@end
