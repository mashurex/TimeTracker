//
//  AxnSettingsViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/23/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AxnSettingsViewController.h"

@implementation AxnSettingsViewController

@synthesize txtUsername;
@synthesize txtPassword;
@synthesize lblValidating;
@synthesize lblValid;
@synthesize lblInvalid;
@synthesize switchReminder;
@synthesize btnClearSettings;
@synthesize btnSaveSettings;
@synthesize btnvalidateUser;
@synthesize actValidating;

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
    if(self.ttSettings.hasCredentials)
    {
        [self.txtUsername setText:self.ttSettings.username];
        [self.txtPassword setText:self.ttSettings.password];
        [self.switchReminder setOn:self.ttSettings.doReminder];
    }
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.txtUsername = nil;
    self.txtPassword = nil;
    self.lblValidating = nil;
    self.lblValid = nil;
    self.lblInvalid = nil;
    self.actValidating = nil;
    self.switchReminder = nil;
    self.btnClearSettings = nil;
    self.btnSaveSettings = nil;
    self.btnvalidateUser = nil;
}

- (void)dealloc
{
    self.txtUsername = nil;
    self.txtPassword = nil;
    self.lblValidating = nil;
    self.lblValid = nil;
    self.lblInvalid = nil;
    self.actValidating = nil;
    self.switchReminder = nil;
    self.btnClearSettings = nil;
    self.btnSaveSettings = nil;
    self.btnvalidateUser = nil;
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)backgroundTap:(id)sender
{
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

/**
 * Validates user input, pops up an alert on validation failure
 * Returns YES if valid, NO otherwise
 */
- (BOOL)isValidSettingsInput
{
    NSString *msg = [[NSString alloc] initWithString:@""];
    NSString *username = self.txtUsername.text;
    NSString *password = self.txtPassword.text;
    BOOL isValid = NO;
    
    if([username length] == 0)
    {
        msg = @"Username required.";
    }
    else if([password length] == 0)
    {
        msg = @"Password required.";
    }
    else { isValid = YES; }
    
    if(!isValid)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Error" 
                              message:msg
                              delegate:self 
                              cancelButtonTitle:@"Ok" 
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
    [msg release];
    return isValid;
}

- (void)showValidatingProcess
{
    [lblValid setHidden:YES];
    [lblInvalid setHidden:YES];
    
    [lblValidating setHidden:NO];
    [actValidating setHidden:NO];
    [actValidating startAnimating];
}

- (void)showUserIsValid
{
    [lblValidating setHidden:YES];
    [lblValid setHidden:NO];
}

- (void) showUserIsInvalid
{
    [lblValidating setHidden:YES];
    [lblInvalid setHidden:NO];
}

#pragma mark -
#pragma mark Button/UI Events

- (IBAction)btnValidateUser_Pressed:(id)sender
{
    [self backgroundTap:nil];
    
    if([self isValidSettingsInput])
    {
        [self showValidatingProcess];  
        ASIHTTPRequest *request = [self createLoginRequest:self.txtUsername.text 
                                              withPassword:self.txtPassword.text];
        [request setDelegate:self];
        [request startAsynchronous];
        
    }
}

@end
