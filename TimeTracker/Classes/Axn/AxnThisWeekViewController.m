//
//  AxnThisWeekViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 2/1/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnThisWeekViewController.h"

@implementation AxnThisWeekViewController

@synthesize tbvEntries          = _tbvEntries;
@synthesize isReloading         = _isReloading;
@synthesize refreshHeaderView   = _refreshHeaderView;
@synthesize thisWeekDates       = _thisWeekDates;
@synthesize weekEntries         = _weekEntries;
@synthesize outstandingRequests = _outstandingRequest;
@synthesize hasLoadedEntries    = _hasLoadedEntries;

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
    self.hud.detailsLabelText = @"Fetching Daily Details";
    
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.thisWeekDates = [self getCurrentWeekDates];
    self.weekEntries = [[NSMutableDictionary alloc] initWithCapacity:7];
    
    //self.tbvEntries.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bground.png"]];
    
    if(!self.refreshHeaderView)
    {
        EGORefreshTableHeaderView *refresh = [[EGORefreshTableHeaderView alloc] 
                                              initWithFrame:CGRectMake(0.0f, 0.0f - self.tbvEntries.bounds.size.height, 
                                                                       self.view.frame.size.width, 
                                                                       self.tbvEntries.bounds.size.height)];
        refresh.delegate = self;
        [self.tbvEntries addSubview:refresh];
        self.refreshHeaderView = refresh;
        [refresh release];
    }
    self.hasLoadedEntries = NO;
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    if(!self.hasLoadedEntries)
    {
        [self.refreshHeaderView refreshLastUpdatedDate];
        [self refreshAllDates];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.tbvEntries         = nil;
    self.refreshHeaderView  = nil;
    self.thisWeekDates  = nil;
    self.weekEntries = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)incrementOutstandingRequests
{
	[self setOutstandingRequests:(self.outstandingRequests + 1)];
}

-(void)decrementOutstandingReuqests
{
	[self setOutstandingRequests:(self.outstandingRequests - 1)];
}


#pragma mark - Date Methods

- (int)getDateArrayPosition: (NSDate *)date
{
	if(date == nil){ return -1; }
	
	int i;
	for(i = 0; i < [self.thisWeekDates count]; i++)
	{
		NSDate *curDate = [self.thisWeekDates objectAtIndex:i];
		
		if(curDate != nil)
		{
			if([curDate compare:date] == NSOrderedSame) { return i; }
		}
	}
	return -1;
}

- (NSArray *)getCurrentWeekDates
{
	NSMutableArray *weekDates = [[[NSMutableArray alloc] initWithCapacity:7] autorelease];
	NSDate *now = [NSDate date];
	NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
	NSDateComponents *components = [cal components:( NSYearCalendarUnit | NSMonthCalendarUnit | NSWeekCalendarUnit | NSWeekdayCalendarUnit ) fromDate:now];
	
	for(int i = 2; i < 8; i++)
	{
		[components setWeekday:i];
		NSDate *newDate = [cal dateFromComponents:components];
		[weekDates addObject:newDate];
	}
	
	[components setWeek:(components.week + 1)];
	[components setWeekday:1];
	NSDate *newDate = [cal dateFromComponents:components];
	[weekDates addObject:newDate];
	
	[cal release];
	return (NSArray *)weekDates;
}

/**
 * Turn an integer into the day of the week (0 is Monday, 6 is Sunday)
 * @param NSInteger day - The integer to convert to a string
 * @return NSString - The full English name of the day
 */
- (NSString *)convertNSIntegerToDayOfWeek:(NSInteger)day
{
	switch(day)
	{
		case 0:
			return @"Monday";
			break;
		case 1:
			return @"Tuesday";
			break;
		case 2:
			return @"Wednesday";
			break;
		case 3:
			return @"Thursday";
			break;
		case 4:
			return @"Friday";
			break;
		case 5:
			return @"Saturday";
			break;
		case 6:
			return @"Sunday";
			break;
		default:
			return @"Unknown";
			break;
	}
}

- (NSString *)convertDateToKeyString:(NSDate *)date
{
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"yyyyMMdd"];
	return [df stringFromDate:date];
}

#pragma mark - Project Entry Gathering

- (void)fetchEntriesForDate: (NSDate *)date
{
	NSString *strDate = [self convertDateToRequestString:date];
	NSDictionary *requestParams = [[NSDictionary alloc] initWithObjectsAndKeys:strDate, @"date", nil];
	NSURL *url =[NSURL URLWithString: sGetEntriesUrl];
	AxnDbgLog(@"Fetching entry for date: %@", strDate);
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:requestParams];
	[request setDelegate:self];
	[request setTag: kRequest_FetchEntriesTag];
	[request startAsynchronous];		
	[self incrementOutstandingRequests];
}

- (void)refreshAllDates
{
    [self showFetchingEntriesHud:nil];
	for(int i = 0; i < [self.thisWeekDates count]; i++)
	{
		[self fetchEntriesForDate:(NSDate *)[self.thisWeekDates objectAtIndex:i]];
	}
}

#pragma mark - ASIHTTPRequest Delegate Methods

- (void)requestFinished:(ASIHTTPRequest *)request
{	
	// Error object for string to json process
	NSError *error = nil;
		
	// Response string from the HTTP request
	NSString *responseString = [request responseString];
        
    NSDictionary *jsonData = [self getJsonDataFromResponseString:responseString error:&error];
    if(!jsonData)
    {
        [self showAlert:@"Error" withMessage:@"Could not fetch data."];
    }
    else
    {
        NSArray *dData = [jsonData objectForKey:sTimeTrackerDataDicKey];
        
        
        if(!dData)
        {
            AxnDetailLog(@"No or invalid data returned.");
            if(error)
            {
                AxnDetailLog(@"Error: %@", [error localizedDescription]);
            }
        }
        else 
        {
            // Hold TimeEntry objects as they are compiled
            NSMutableDictionary *dictProjects = [[NSMutableDictionary alloc] init];
            NSMutableDictionary *dictHours = [[NSMutableDictionary alloc] init];
            
            // Date formatter for creating an entry date from the response
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            [df setDateFormat:@"yyyyMMdd"];

            // Each item in the array will return an entry date, but we only need
            // to set one (they're all the same!)
            NSDate *entryDate = nil;
            NSString *dateKeyString = nil;
            
            int i;
            for(i = 0; i < [dData count]; i++)
            {
                NSDictionary	*dicEntryData	= [dData objectAtIndex:i];
                NSString		*strEntryDate	= [[dicEntryData objectForKey:@"CalendarId"] stringValue];
                
                if(!entryDate)
                {
                    AxnDbgDtlLog(@"Setting entryDate to: %@", strEntryDate);
                    dateKeyString = strEntryDate;
                }
                
                entryDate                       = [df dateFromString:strEntryDate];
                AxnProject      *proj			= [[AxnProject alloc] initWithDictionary:dicEntryData];
                float			hours			= [[dicEntryData objectForKey:@"Hours"] floatValue];
                // Turn the project id into a string so we can use it as a key for the dictionaries
                NSString		*strProjectId	= [NSString stringWithFormat:@"%i", proj.projectId];
                
                // Check and see if we have already stored time for the project we are looking at
                AxnProject *existingProject = [dictProjects objectForKey:strProjectId];			
                if(existingProject == nil)
                {
                    // No project was found, push in a new one
                    AxnDbgDtlLog(@"Adding project (%@) with %2.1f hours.", proj, hours);
                    [dictProjects setObject:proj forKey:strProjectId];
                    [dictHours setObject:[NSNumber numberWithFloat:hours] forKey:strProjectId];
                }
                else 
                {
                    // Project was found, add hours to what is already in there
                    float existingHours = [[dictHours objectForKey:strProjectId] floatValue] + hours;
                    AxnDbgDtlLog(@"Found project (%@) already, adding %2.1f to existing %2.1f hours.", proj, hours, existingHours);				
                    [dictHours setObject:[NSNumber numberWithFloat:existingHours] forKey:strProjectId]; 
                }
                
                [proj release];			
            }
            
            // If we didn't get an entryDate (for whatever reason) don't bother
            // even trying to put the results into storage- we wouldn't know where
            // to put them.
            if(entryDate != nil)
            {
                int idx = [self getDateArrayPosition:entryDate];
                if(idx < 0) { NSLog(@"No index returned for date: %@", entryDate); }
                else 
                {
                    // NSLog(@"Date index is %i for date: %@", idx, entryDate);
                    NSMutableArray *dayEntries = [[NSMutableArray alloc] init];
                    for(NSString *key in dictProjects)
                    {
                        NSDictionary *projectEntry = [[NSDictionary alloc] initWithObjectsAndKeys:
                                                      [dictProjects objectForKey:key], @"project",
                                                      [dictHours objectForKey:key],@"hours", nil];
                        [dayEntries addObject:projectEntry];
                        [projectEntry release];
                    }
                    
                    // Keeps the controller from refreshing the data every time you come back to it
                    self.hasLoadedEntries = YES;
                    
                    [self.weekEntries setObject:dayEntries forKey:dateKeyString];
                    [dayEntries release];
                }
            }
            
            [df release];
            [dictProjects release];
            [dictHours release];
        }
    }
    
	[self decrementOutstandingReuqests];
	
	if(self.outstandingRequests == 0)
	{
        [self showCompletedEntriesHud:nil];
		[self doneLoadingTableViewData];
		// Refresh the table view data
		[self.tbvEntries reloadData];
	}
	else 
	{
		// TODO: Eventually implement a staged progress hud?
		// [table reloadData];
	}
}


- (void)requestFailed:(ASIHTTPRequest *)request
{
	// NSError *error = [request error];
    // NSLog(@"requestFailed: %@",[error localizedDescription]);
	[self decrementOutstandingReuqests];
	// [self doneLoadingTableViewData];
    [super requestFailed:request];
    // TODO: Count outstanding requests, be able to cancel them, etc.
    if(self.outstandingRequests == 0)
    {
        [self.hud hide:YES];
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

-(NSArray *)getProjectEntriesForSection:(NSInteger)section
{
	NSString *key = (NSString *)[self convertDateToKeyString:(NSDate *)[self.thisWeekDates objectAtIndex:section]];
	return (NSArray *)[self.weekEntries objectForKey:key];
}

#pragma mark - Table Methods

/**
 * Return the number of sections for the table view
 */
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	// A section for each date to display
	return [self.thisWeekDates count];
}

/**
 * Return the indentation level for the row
 * Currently set to always return 0, possible to implement
 * some type of fancy indentation levels
 */
- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath { return 0; }

/**
 * Return the selected indexPath
 */
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath { return indexPath; }

/**
 * Returns the number of rows in the table section
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	// Count the entries for the date of the section
	NSArray *dayEntries = (NSArray *)[self getProjectEntriesForSection:section];
	return [dayEntries count];
}

/**
 * Return section titles
 */
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	// Return a section title with month, day, and weekday name, like this: 12-01 Monday
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"MM-dd"];
	return [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:[self.thisWeekDates objectAtIndex:section]], [self convertNSIntegerToDayOfWeek:section]];
}

/**
 * Return UITableViewCell at index (used for populating)
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
	static NSString *SimpleTableIdentifier = @"ThisWeekCell";
	// Reuse a cell that has already been drawn if possible
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:SimpleTableIdentifier];
	// Otherwise instantiate a new cell
	/*if(cell == nil)
	{
		cell = [[[UITableViewCell alloc]
				 initWithStyle:UITa 
				 reuseIdentifier:SimpleTableIdentifier] autorelease];
	}*/
	
	NSUInteger row = [indexPath row];
	
	NSArray *dayEntries = (NSArray *)[self getProjectEntriesForSection:indexPath.section];
	NSDictionary *dicDay = [dayEntries objectAtIndex:row];
	AxnProject *project = (AxnProject *)[dicDay objectForKey:@"project"];
	float hours = [[dicDay objectForKey:@"hours"] floatValue];

	cell.textLabel.text = [NSString stringWithFormat:@"%@", project.projectAbbrv];
    // cell.textLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%2.2f hrs", hours];
    // cell.detailTextLabel.textColor = [UIColor whiteColor];
	return cell;
	
}

#pragma mark - EGORefreshTableHeaderDelegate Methods

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

#pragma mark - EGORefreshTableHeaderView 

- (void)reloadTableViewDataSource
{
	self.isReloading = YES;
	[self refreshAllDates];
}

- (void)doneLoadingTableViewData
{
	self.isReloading = NO;
	[self.refreshHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbvEntries];
}


@end
