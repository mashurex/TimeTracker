//
//  AxnStartupViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
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
    NSLog(@"view did load");
}
- (void)viewWillAppear:(BOOL)animated
{
    if(self.comingFromLogin)
    {
        self.comingFromLogin = NO;
        // TODO: Fetch projects
        
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if(([self.ttSettings.username length] > 0)&&([self.ttSettings.password length] > 0))
    {
        ASIHTTPRequest *request = [self createLoginRequest:self.ttSettings.username withPassword:self.ttSettings.password];
        [request setDelegate:self];
        [request startAsynchronous];
    }
    else
    {
        self.comingFromLogin = YES;
        [self performSegueWithIdentifier:sLoginSegue sender:self];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSError *error;
	NSDictionary *response = [self getJsonDataFromResponseString:[request responseString] error:&error];
    if(!response)
    {
        NSLog(@"AxnStartupViewController requestFinished error: %@", [error localizedDescription]);
        return;
    }
    
    // Response is for authentication
    if(request.tag == kRequest_AuthenticateTag)
    {
        BOOL isValid = [[response objectForKey:sTimeTrackerDataDicKey] boolValue];
        if(isValid)
        {
            // Valid login, set flag and show tab bar
            self.ttSettings.hasLoggedIn = YES;
            [self performSegueWithIdentifier:sTabBarSegue sender:self];
        }
        // Invalid login, show login form
        else { [self performSegueWithIdentifier:sLoginSegue sender:self]; }
    }
	
}

@end
