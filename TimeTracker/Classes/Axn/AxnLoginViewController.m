//
//  AxnLoginViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/25/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnLoginViewController.h"

@implementation AxnLoginViewController

@synthesize btnLogin    = _btnLogin;
@synthesize txtPassword = _txtPassword;
@synthesize txtUsername = _txtUsername;

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

- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.btnLogin = nil;
    self.txtUsername = nil;
    self.txtPassword = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL) validateInput
{
	BOOL isValid = YES;
	NSString *message = @"";
	if([self.txtUsername.text length] < 1)
	{ 
		message = @"Username is required.";
		isValid = NO; 
	}
	else if([self.txtPassword.text length] < 1)
	{ 
		message = @"Password is required.";
		isValid = NO; 
	}
	
	if(!isValid)
	{
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Error"
							  message:message 
							  delegate:self 
							  cancelButtonTitle:@"Ok" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
	
	return isValid;
}

#pragma mark - Button/UI Events

- (IBAction)resignAllResponders:(id)sender 
{
    [self.txtUsername resignFirstResponder];
    [self.txtPassword resignFirstResponder];
}

- (IBAction) buttonLogin_Pressed
{
	if(![self validateInput])
	{ 
		return;
	}
    
	self.ttSettings.username = self.txtUsername.text;
	self.ttSettings.password = self.txtPassword.text;
		
    ASIHTTPRequest *request = [self createLoginRequest:self.txtUsername.text withPassword:self.txtPassword.text];
    [request setDelegate:self];
    [request startAsynchronous];
}

#pragma mark - HTTP Requests

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSError *error;
	NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
	BOOL isValid = [[jsonData objectForKey:sTimeTrackerDataDicKey] boolValue];
	if(isValid)
	{
		self.ttSettings.hasLoggedIn = YES;
        [self.ttSettings saveSettings];
		[self dismissModalViewControllerAnimated:YES];
	}
	else 
	{
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Error"
							  message:@"Incorrect username/password" 
							  delegate:self 
							  cancelButtonTitle:@"Ok" 
							  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [super requestFailed:request];
    
    NSString *msg = @"Error logging in.";
    if([self requestFailedOnAuth:request])
    {
       msg = @"Invalid username/password.";
    }
    
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:@"Error" 
                          message:msg
                          delegate:self 
                          cancelButtonTitle:@"Ok" 
                          otherButtonTitles:nil];
    [alert show];
    [alert release];
    [msg release];
}
@end
