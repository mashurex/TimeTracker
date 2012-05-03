//
//  AxnStartupViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/28/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnStartupViewController.h"

@implementation AxnStartupViewController

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

#pragma mark - View lifecycle

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
   
}

- (void)viewWillAppear:(BOOL)animated
{
    if(self.comingFromLogin)
    {
        self.comingFromLogin = NO;

        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.delegate = self;
        self.hud.labelText = sFetchingProjectsLabelText;
        self.hud.removeFromSuperViewOnHide = YES;    
        [self.hud show: YES];
        // TODO: Move this out of startup
        ASIHTTPRequest *requestProjects = [self createFetchProjectsRequest];
        [requestProjects setDelegate:self];
        [requestProjects startAsynchronous];
 
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(([self.ttSettings.username length] > 0)&&([self.ttSettings.password length] > 0))
    {
        // NSLog(@"Logging in %@",self.ttSettings.username);
        [self showLoggingInHud];
        ASIHTTPRequest *request = [self createLoginRequest:self.ttSettings.username withPassword:self.ttSettings.password];
        [request setDelegate:self];
        [request startAsynchronous];
    }
    else
    {
        [self showLoginForm:sLoginSegue sender:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

/**
 * Initialize and display MBProgressHUD with logging in message
 */
- (void)showLoggingInHud
{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.delegate = self;
	self.hud.labelText = @"Logging In...";
	self.hud.removeFromSuperViewOnHide = YES;    
	[self.hud show: YES];
}

/**
 * Display success message and hide MBProgressHUD that was displayed
 * via showLoggingInHud
 */
- (void)hideLoginHudAfterSuccess
{
    self.hud.customView = [[[UIImageView alloc] 
                            initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] 
                           autorelease];
    
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = @"Success";
    self.hud.detailsLabelText = @"";
    [self.hud hide:YES afterDelay:0.75];
}

/**
 * ASIHTTPRequest Failed
 */
- (void)requestFailed:(ASIHTTPRequest *)request
{
    self.hud.labelText = @"Request failed!";
    [self hideHud:0.75];
    [super requestFailed:request];
    
    if(([self requestFailedOnAuth:request])||(request.tag == kRequest_AuthenticateTag))
    {
        [self showLoginForm:sLoginSegue sender:self];
    }
}

/**
 * ASIHTTPRequest Finished
 */
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
	NSDictionary *response = [self getJsonDataFromResponseString:[request responseString] error:&error];

    if(!response)
    {        

        AxnDetailLog(@"Request error: %@", [request responseString]);
        
        if(request.tag == kRequest_AuthenticateTag)
        {
            // Couldn't login, show the login form
            self.hud.labelText = sHudMsg_LoginError;
            [self hideHud:0.75];
            [self showLoginForm:sLoginSegue sender:self];
        }
        else if(request.tag == kRequest_FetchProjectsTag)
        {
            // Even through the request didn't successfully complete,
            // other views can load projects details, so move on.
            self.hud.labelText = sHudMsg_ProjectsError;
            [self hideHud:0.75];
            [self performSegueWithIdentifier:sTabBarSegue sender:self];
        }
        
        return;
    }
    
    // Response is for authentication
    if(request.tag == kRequest_AuthenticateTag)
    {
        BOOL isValid = [[response objectForKey:sTimeTrackerDataDicKey] boolValue];
        if(isValid)
        {
            // Login done, change HUD text to fetching projects
            self.hud.labelText = @"Loading...";
            self.hud.detailsLabelText = sFetchingProjectsLabelText;
            
            // Valid login, set flag and gather user projects/tasks
            self.ttSettings.hasLoggedIn = YES;
            [self performSegueWithIdentifier:sTabBarSegue sender:self];

            // TODO: Move this out of startup
            ASIHTTPRequest *requestProjects = [self createFetchProjectsRequest];
            [requestProjects setDelegate:self];
            [requestProjects startAsynchronous];
        }
        else 
        {
            // Invalid login, hide HUD and segue to login form
            [self hideHud:0.0];
            [self showLoginForm:sLoginSegue sender:self];
        }
    }
    // Response is for project entry details
    else if(request.tag == kRequest_FetchProjectsTag)
    {
        // NSLog(@"Startup: projects response, building data");
        NSMutableArray *projectsArray = [[NSMutableArray alloc] init];
		// Get all the entry collections from the response
		NSArray *entries = [response objectForKey:sTimeTrackerDataDicKey];

		// Iterate through them and initialize each TimeEntry object
		for(int i = 0; i < [entries count]; i++)
		{
			NSDictionary *entryDic = [entries objectAtIndex:i];
			AxnProject *entry = [[AxnProject alloc] initWithDictionary:entryDic];
			NSArray *features = [self fetchFeatures:entry.projectId];
			if(features != nil)
			{
				for(int j = 0; j < [features count]; j++)
				{
					AxnFeature *f = [features objectAtIndex:j];
					f.featureTasks = [self fetchTasks:entry.projectId forFeature:f.featureId];
				}
				entry.projectFeatures = features;
				[projectsArray addObject:entry];
				[entry release];		
			}
		}
        
        // Success - Hide the hud and segue to the rest of the app
		[self hideLoginHudAfterSuccess];
		self.ttSettings.axianProjects = (NSArray *)projectsArray;
		[projectsArray release];
        
        [self performSegueWithIdentifier:sTabBarSegue sender:self];
    }	
}

@end
