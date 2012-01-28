//
//  AxnViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/22/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "TTSettings.h"
#import "TTSettingsDelegateProtocol.h"
#import "AxnProject.h"
#import "AxnFeature.h"
#import "AxnTask.h"

@implementation AxnBaseViewController

@synthesize ttSettings = _ttsettings;

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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setTtSettings: [self timeTrackerSettings]];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (TTSettings *) timeTrackerSettings;
{
	id<TTSettingsDelegateProtocol> theDelegate = 
    (id<TTSettingsDelegateProtocol>) [UIApplication sharedApplication].delegate;
	TTSettings *settings;
	settings = (TTSettings *) theDelegate.timeTrackerSettings;
	return settings;
}

- (IBAction)textFieldDoneEditing:(id)sender 
{
    [sender resignFirstResponder];
}

-(NSString *)todayString
{
	NSDate *today = [NSDate date];
	return [self convertDateToRequestString:today];
}

-(NSString *)convertDateToRequestString: (NSDate *)date
{
	NSDateFormatter *frmt = [[[NSDateFormatter alloc] init] autorelease];
	frmt.dateFormat = @"yyyy-MM-dd";
	return [frmt stringFromDate:date];
}

@end
