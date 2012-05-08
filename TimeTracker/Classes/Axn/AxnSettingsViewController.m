//
//  AxnSettingsViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/23/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnSettingsViewController.h"

@implementation AxnSettingsViewController

@synthesize txtUsername;
@synthesize txtPassword;
@synthesize lblValidating;
@synthesize lblValid;
@synthesize lblInvalid;
@synthesize lblReminderTime;
@synthesize switchReminder;
@synthesize btnClearSettings;
@synthesize btnSaveSettings;
@synthesize btnvalidateUser;
@synthesize btnSetReminder;
@synthesize actValidating;
@synthesize datePicker;
@synthesize reminderDate;

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

- (void)displaySettingsValues
{
    if(self.ttSettings.hasCredentials)
    {
        [self.txtUsername setText:self.ttSettings.username];
        [self.txtPassword setText:self.ttSettings.password];
        [self.switchReminder setOn:self.ttSettings.doReminder];
        [self.btnSetReminder setEnabled:self.ttSettings.doReminder];
        
        if(self.ttSettings.doReminder)
        {
            self.lblReminderTime.text = [self.ttSettings getReminderTimeAsString];
            self.reminderDate = self.ttSettings.reminderDate;
        }
    }
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self displaySettingsValues];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self displaySettingsValues];
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
    
    if(isValid && (self.switchReminder.on))
    {
        if(self.reminderDate == nil)
        { 
            isValid = NO;
            msg = @"You must set a reminder time or turn off alerts.";
        }
    }
    
    if(!isValid)
    {
        [self showAlert:@"Error" withMessage:msg];
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
    [actValidating stopAnimating];
    [lblValidating setHidden:YES];
    [lblInvalid setHidden:YES];
    [lblValid setHidden:NO];
}

- (void)showUserIsInvalid
{
    [actValidating stopAnimating];
    [lblValidating setHidden:YES];
    [lblValid setHidden:YES];
    [lblInvalid setHidden:NO];
}

- (void)hideValidatingLabels
{
    [lblValid setHidden:YES];
    [lblInvalid setHidden:YES];
    [lblValidating setHidden:YES];
    [actValidating setHidden:YES];
    [actValidating stopAnimating];
}

#pragma mark -
#pragma mark Button/UI Events

- (IBAction)backgroundTap:(id)sender
{
    [txtUsername resignFirstResponder];
    [txtPassword resignFirstResponder];
}

- (IBAction)btnSetReminder_Pressed:(id)sender
{
    UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle: @"Set Alarm Time" 
                                   delegate: self 
                                   cancelButtonTitle: @"Cancel" 
                                   destructiveButtonTitle: nil 
                                   otherButtonTitles: @"Set Reminder", nil] autorelease];
    
	[actionSheet setTag: kAlarmPickerTag];
	[actionSheet showInView: self.view.superview];
	[actionSheet setFrame: CGRectMake(0,117,320,383)];
}



- (IBAction)btnSaveSettings_Pressed:(id)sender
{
    if([self isValidSettingsInput])
    {
        [self hideValidatingLabels];
        self.ttSettings.username = self.txtUsername.text;
        self.ttSettings.password = self.txtPassword.text;
        
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
            
        if(self.switchReminder.on)
        {
            self.ttSettings.doReminder = YES;
            self.ttSettings.reminderDate = self.reminderDate;
            
            /* 
            Class cls = NSClassFromString(@"UILocalNotification");
            if (cls != nil) {
                
                UILocalNotification *notif = [[cls alloc] init];
                notif.fireDate = [self.datePicker date];
                notif.timeZone = [NSTimeZone defaultTimeZone];

                notif.alertBody = @"Don't forget your time entry!";
                notif.alertAction = @"Do it now";
                notif.soundName = UILocalNotificationDefaultSoundName;
                notif.repeatInterval = NSWeekdayCalendarUnit;
                
                [[UIApplication sharedApplication] scheduleLocalNotification:notif];
                [notif release];
            }
            */
            [self setWeekdayUILocalNotifcations:[self.datePicker date]];
        }
        else
        {
            self.ttSettings.reminderDate = nil;
            self.ttSettings.doReminder = NO;
        }
        
        [self.ttSettings saveSettings];
        [self showAlert:@"Success" withMessage:@"Settings saved."];
    }
}

- (NSDate*) getDateForAlarmWithTime:(NSDate *)alarmTime forDay:(int)weekDay
{
    NSDate *today = [[[NSDate alloc] init] autorelease];
    NSCalendar *calendar = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    [calendar setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *alarmComponents = [calendar components: NSHourCalendarUnit | NSMinuteCalendarUnit fromDate:alarmTime];
    NSDateComponents *components = [calendar components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    [components setWeekday: weekDay];
    [components setHour:[alarmComponents hour]];
    [components setMinute:[alarmComponents minute]];
    [components setSecond:0];
    
    return [calendar dateFromComponents: components];
}

- (void) setWeekdayUILocalNotifcations:(NSDate *)alarmTime
{
    // NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    for(int i = 2; i <=6; i++)
    {
        UILocalNotification *localNotifcation = [[UILocalNotification alloc] init];
        if(localNotifcation == nil){ return; }

        // localNotifcation.repeatCalendar = gregorian;
        NSDate *date = [self getDateForAlarmWithTime:alarmTime forDay:i];
        localNotifcation.fireDate = date;
        localNotifcation.timeZone = [NSTimeZone defaultTimeZone];
        localNotifcation.alertBody = @"Don't forget your time entry!";
        localNotifcation.alertAction = @"Do it now";
        localNotifcation.soundName = UILocalNotificationDefaultSoundName;
        localNotifcation.repeatInterval = NSWeekCalendarUnit;
        
        NSLog(@"Setting notification for: %@", date);
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotifcation];
        [localNotifcation release];
    }
}

- (IBAction)btnClearSettings_Pressed:(id)sender
{
    [self.ttSettings clearSettings];
    [ASIHTTPRequest setSessionCookies:nil];
    
    self.txtUsername.text = @"";
    self.txtPassword.text = @"";
    
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    self.lblReminderTime.text = @"--:--";
    self.switchReminder.on = NO;
    self.btnSetReminder.enabled = NO;
    
    [self showAlert:@"Success" withMessage:@"Settings cleared."];
}

- (IBAction)switchReminder_Toggled:(id)sender
{
    self.btnSetReminder.enabled = self.switchReminder.on;
    if(!self.switchReminder.on)
    {
        self.lblReminderTime.text = @"--:--";
        self.reminderDate = nil;
    }
    
}

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

#pragma mark -
#pragma mark ActionSheet Delegate Methods

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet
{
    if(actionSheet.tag == kAlarmPickerTag)
    {
        self.datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
        [self.datePicker setTag:kAlarmPickerTag];
        [self.datePicker setDatePickerMode:UIDatePickerModeTime];
        // TODO: Set time from current time
        [actionSheet addSubview:self.datePicker];

        NSArray *subviews = [actionSheet subviews];
        [[subviews objectAtIndex:1] setFrame:CGRectMake(20, 266, 280, 46)]; 
		[[subviews objectAtIndex:2] setFrame:CGRectMake(20, 317, 280, 46)];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(buttonIndex == actionSheet.cancelButtonIndex){ return; }
    
    self.reminderDate = [self.datePicker date];

    NSDateFormatter *frmt = [[NSDateFormatter alloc] init];
    frmt.dateFormat = sDisplayReminderFormat;
    self.lblReminderTime.text = [frmt stringFromDate:self.reminderDate];
    [frmt release];
}

#pragma mark - HTTP Requests

- (void)requestFinished:(ASIHTTPRequest *)request
{
    [self.actValidating stopAnimating];
	
	NSError *error = nil;
    NSDictionary *response = [self getJsonDataFromResponseString:[request responseString] error:&error];
	
    if(!response)
	{
		NSLog(@"Error parsing response for: %@", [request responseString]);
        [self hideValidatingLabels];
	}
	
    BOOL result = [[response objectForKey:sTimeTrackerDataDicKey] boolValue];
    if(result)
    {
        [self showUserIsValid];
    }
    else
    {
        [self showUserIsInvalid];
    }
    [self.actValidating setHidden:YES];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	NSError *error = [request error];
    NSString *msg = @"";
    if(![self requestFailedOnAuth:request])
    {
        msg = [error localizedDescription];
    }
    else
    {
        msg = @"Invalid username/password";
    }
    
    NSLog(@"Validation request failed: %@",[request responseString]);
    
    [self hideValidatingLabels];
    [self showAlert:@"Error" withMessage:msg];
    [msg release];
    [self.actValidating setHidden:YES];
}


@end
