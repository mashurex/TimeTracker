//
//  AxnEditTimeEntryViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/31/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnEditTimeEntryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Three20/Three20.h"
#import "Three20/Three20+Additions.h"

@implementation AxnEditTimeEntryViewController

@synthesize delegate            = _delegate;
@synthesize timeEntry           = _timeEntry;
@synthesize lblProject          = _lblProject;
@synthesize lblProjectBorder    = _lblProjectBorder;
@synthesize lblTask             = _lblTask;
@synthesize lblTaskBorder       = _lblTaskBorder;
@synthesize lblFeature          = _lblFeature;
@synthesize lblFeatureBorder    = _lblFeatureBorder;
@synthesize lblDescription      = _lblDescription;
@synthesize lblDescriptionBorder = _lblDescriptionBorder;
@synthesize lblHours            = _lblHours;
@synthesize lblHoursBorder      = _lblHoursBorder;
@synthesize pickHours           = _pickHours;
@synthesize wereChangesMade     = _wereChangesMade;
@synthesize curHours            = _curHours;
@synthesize curDescription      = _curDescription;
@synthesize keyboardIsShown     = _keyboardIsShown;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) 
    {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
}

// Applies a specific black radiused border around the specified label
- (void)applyRadiusBorder:(UILabel *)label
{
    label.layer.borderColor = [UIColor blackColor].CGColor;
    label.layer.borderWidth = 1.0;
    label.layer.cornerRadius = 4;
}

// Applies a tap gesture recognizer that will fire the action defined in the selector
- (void)applyTapGestureRecognizer:(UILabel *)label action:(SEL)selector
{
    label.userInteractionEnabled = YES;
    UITapGestureRecognizer *gesture = [[[UITapGestureRecognizer alloc] initWithTarget:self action:selector] autorelease];
    [label addGestureRecognizer:gesture];
}

- (void)setLabelTexts:(BOOL)useCurrentValues
{
    float hours = self.timeEntry.hours;
    NSString *description = self.timeEntry.notes;
    
    if(useCurrentValues)
    {
        NSLog(@"Using current values");
        hours = self.curHours;
        description = self.curDescription;
    }
    
    self.lblHours.text = [NSString stringWithFormat:@"%2.2f", hours];
    self.lblDescription.text = description;
}

- (void)setupFormLabels
{
    //[self applyTapGestureRecognizer:self.lblProject action:@selector(lblProject_Pressed)];
	[self applyRadiusBorder:self.lblProjectBorder];
    
    self.lblProjectBorder.text = @"";
    self.lblProject.text = self.timeEntry.projectName;
    
    //[self applyTapGestureRecognizer:self.lblFeature action:@selector(lblFeature_Pressed)];
	[self applyRadiusBorder:self.lblFeatureBorder];
    
    self.lblFeatureBorder.text = @"";
    self.lblFeature.text = self.timeEntry.featureName;
    
    //[self applyTapGestureRecognizer:self.lblTask action:@selector(lblTask_Pressed)];
	[self applyRadiusBorder:self.lblTaskBorder];
    
    self.lblTaskBorder.text = @"";
    self.lblTask.text = self.timeEntry.taskName;
    
    [self applyTapGestureRecognizer:self.lblHours action:@selector(lblHours_Pressed)];
	[self applyRadiusBorder:self.lblHoursBorder];
    
    
    [self applyTapGestureRecognizer:self.lblDescription action:@selector(lblDescription_Pressed)];
	[self applyRadiusBorder:self.lblDescriptionBorder];
    
    self.lblHoursBorder.text = @"";
    self.lblDescriptionBorder.text = @"";
    [self setLabelTexts:NO];
}

- (BOOL)changedDetails
{    
    if(![self.curDescription isEqualToString:self.timeEntry.notes])
    {
        self.wereChangesMade = YES;
    }    
    else if(self.curHours != self.timeEntry.hours)
    { 
        self.wereChangesMade = YES; 
    }
    else { self.wereChangesMade = NO; }
    
    return self.wereChangesMade;
}

- (void)hudWasHidden:(MBProgressHUD *)hud 
{
    // Remove HUD from screen when the HUD was hidden
    [self.hud removeFromSuperview];
    [self.hud release];
	self.hud = nil;
}


- (IBAction)showSavingEntryHud:(id)sender
{
    self.hud = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:self.hud];
    
    self.hud.delegate = self;
    self.hud.labelText = @"Saving...";    
    [self.hud show:YES];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{        
    [super viewDidLoad];
    
    // Create a save button and put it in the naviation bar
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc]
                                   initWithTitle: @"Save"
                                   style:UIBarButtonItemStyleBordered
                                   target: self
                                   action: @selector(btnSave_Pressed:)];
    self.navigationItem.rightBarButtonItem = saveButton;
	
    [saveButton release];
    
    self.curHours       = self.timeEntry.hours;
    self.curDescription = self.timeEntry.notes;
    
    [self setupFormLabels];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
	[self.navigationController setNavigationBarHidden: NO];    
    [self setLabelTexts:self.keyboardIsShown];
    self.keyboardIsShown = NO;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    self.timeEntry = nil;
    self.lblProject = nil;
    self.lblTask = nil;
    self.lblFeature = nil;
    self.lblDescription = nil;
    self.lblHours = nil;
    self.lblProjectBorder = nil;
    self.lblTaskBorder = nil;
    self.lblFeatureBorder = nil;
    self.lblDescriptionBorder = nil;
    self.lblHours = nil;
    self.pickHours = nil;
    self.curDescription = nil;
}

- (void)dealloc
{
    [_timeEntry release];
    [_lblProject release];
    [_lblTask release];
    [_lblFeature release];
    [_lblDescription release];
    [_lblHours release];
    [_lblProjectBorder release];
    [_lblTaskBorder release];
    [_lblFeatureBorder release];
    [_lblDescriptionBorder release];
    [_lblHoursBorder release];
    [_pickHours release];
    [_curDescription release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - UI/Press Methods

- (IBAction)btnSave_Pressed:(id)sender
{
    if(![self changedDetails])
    {
        [self showAlert:@"Nothing to do" withMessage:@"No changes were made!"];
        return;
    }
    
	NSString *msg = nil;
    
   	if(self.curHours == 0)
	{
		msg = @"No hours entered.";
	}
	else if((self.curDescription == nil)||([self.curDescription length] < 1))
	{
		msg = @"No description entered.";
	}
	
	// Validation errors occurred, show an alert
	if(msg != nil)
	{
		[self showAlert:@"Validation Error" withMessage:msg];
	}
	// Everything validated, post new entry data
	else 
	{
		[self postNewEntryData];
	}
}

- (void)lblHours_Pressed
{ 
   	// TODO: Title isn't displaying hours left, just 0.0
	// float hours = self.curTask.hoursLeft;
	// NSString *title = [[NSString alloc] initWithFormat: @"Hours Remaining: %2.2f", hours];
	NSString *title = @"Set Hours";
	UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle: title 
                                   delegate: self 
                                   cancelButtonTitle: @"Cancel" 
                                   destructiveButtonTitle: nil 
                                   otherButtonTitles: @"Select", nil] autorelease];
	
	[actionSheet setTag: kHoursPickerTag];
	[actionSheet showInView: self.view.superview];
	[actionSheet setFrame: CGRectMake(0,117,320,383)];
	// [title release];
}

- (void)lblDescription_Pressed
{
    // TODO: This is a hack because openPostController isn't firing
    self.keyboardIsShown = YES;
    
    // Create a Three20 post controller for multiline text input pop up
    TTPostController* viewToGo = [[TTPostController alloc] init];
    self.popupViewController = viewToGo;
    viewToGo.superController = self;
    viewToGo.delegate = self;
    viewToGo.textView.text = self.lblDescription.text;
    viewToGo.title = @"Entry Description";
    
    [viewToGo showInView:self.view animated:YES];
    [viewToGo release];
}

- (void)showStandardActionSheet:(NSInteger)tag withTitle:(NSString *)title
{
	UIActionSheet *actionSheet = [[[UIActionSheet alloc]
								   initWithTitle: title 
								   delegate: self 
								   cancelButtonTitle: @"Cancel" 
								   destructiveButtonTitle: nil 
								   otherButtonTitles: @"Select", nil] autorelease];
	
	[actionSheet setTag: tag];
	[actionSheet showInView: self.view.superview];
	[actionSheet setFrame: CGRectMake(0,117,320,383)];
	
}

#pragma mark - ActionSheet Delegates

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{	
	if(buttonIndex == actionSheet.cancelButtonIndex){ return; }
	
    NSTimeInterval duration = self.pickHours.countDownDuration;
    self.curHours = (float)(duration/3600.0f);
    
    NSString *text = [[NSString alloc] initWithFormat: @"%2.2f", self.curHours];
    self.lblHours.text = text;
    [text release];
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet 
{
	if(actionSheet.tag == kHoursPickerTag)
	{
		UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
		float duration = (self.curHours * 3600.0f);
		
        // Configure picker...
		[picker setMinuteInterval: 15];
		[picker setTag: kHoursPickerTag];
		[picker setDatePickerMode: UIDatePickerModeCountDownTimer];
		[picker setCountDownDuration: duration];
        
		//Add picker to action sheet
		[actionSheet addSubview: picker];
		
		self.pickHours = picker;
		[picker release];
		
		//Gets an array af all of the subviews of our actionSheet
		NSArray *subviews = [actionSheet subviews];
		
		[[subviews objectAtIndex:1] setFrame:CGRectMake(20, 266, 280, 46)]; 
		[[subviews objectAtIndex:2] setFrame:CGRectMake(20, 317, 280, 46)];
	}
    self.keyboardIsShown = YES;
}



- (void)showSavingEntryHud
{
    self.hud = [[MBProgressHUD alloc] initWithView: self.navigationController.view];
	self.hud.delegate = self;
	self.hud.labelText = @"Saving changes...";
	self.hud.removeFromSuperViewOnHide = YES;
	[self.navigationController.view addSubview: hud];
	[self.hud show: YES];
}

#pragma mark - HTTP Request Method

- (void)postNewEntryData 
{		
    [self showSavingEntryHud:nil];

    NSMutableDictionary *entry = [[NSMutableDictionary alloc] init];
    [entry setObject:[NSNumber numberWithInt:self.timeEntry.timeEntryId] forKey:@"timeEntryId"];
    [entry setObject:[NSNumber numberWithFloat:self.curHours] forKey:@"hours"];
    [entry setObject:self.curDescription forKey:@"notes"];  

    
    NSURL *url = [NSURL URLWithString:sEditTimeUrl];
    ASIHTTPRequest *request = [self createPostRequest:url withParameters:(NSDictionary *)entry];
    [request setDelegate:self];
    [request setTag:kRequest_SaveEditEntryTag];
    [request startAsynchronous];
}

- (void)requestFinished:(ASIHTTPRequest *)request
{	
    [self.hud hide:YES];
	// Error object for string to json process
	NSError *error = nil;
    NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
    
	if(jsonData == nil)
	{
		NSLog(@"Entry edit save error: %@",[request responseString]);
        [self showAlert:@"Error" withMessage:@"Error saving changes."];
        
	}
	else 
	{
        NSDictionary *data = [jsonData objectForKey:sTimeTrackerDataDicKey];
        
        int newId = [[data objectForKey:@"TimeEntryId"] intValue];
        if(newId == 0)
        {
            NSLog(@"Error submitting entry edit to server: %@", [request responseString]);
            [self showAlert:@"Error" withMessage:@"Error submitting to server."];
        }
        else
        {
            
            self.timeEntry.notes = self.curDescription;
            self.timeEntry.hours = self.curHours;
            [[self delegate] editTimeEntry:self.timeEntry];
            [self.navigationController popViewControllerAnimated:YES];
        }
	}
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
	[self.hud hide:YES];
    [super requestFailed:request];
}

#pragma mark - TTPostController Actions

// TODO: This isn't firing... 
- (IBAction)openPostController:(id)sender
{
    self.keyboardIsShown = YES;
    return;
}

- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text 
{
	// Done was pressed, set the label text with our changes
    self.curDescription = text;
	self.lblDescription.text = self.curDescription;

	return YES;
}

- (void)postControllerDidCancel:(TTPostController*)postController 
{
	return;
}

@end
