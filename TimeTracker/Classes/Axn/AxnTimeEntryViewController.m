//
//  AxnTimeEntryViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/31/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnTimeEntryViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Three20/Three20.h"
#import "Three20/Three20+Additions.h"

@implementation AxnTimeEntryViewController

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

@synthesize wereChangesMade     = _wereChangesMade;
@synthesize pickHours           = _pickHours;
@synthesize isValidated         = _isValidated;
@synthesize curProject          = _curProject;
@synthesize curFeature          = _curFeature;
@synthesize curTask             = _curTask;
@synthesize curHours            = _curHours;
@synthesize curDescription      = _curDescription;
@synthesize pickerView          = _pickerView;
@synthesize selectedProjectRow  = _selectedProjectRow;
@synthesize selectedFeatureRow  = _selectedFeatureRow;
@synthesize selectedTaskRow     = _selectedTaskRow;
@synthesize projects            = _projects;

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

- (void)setupFormLabels
{
    [self applyTapGestureRecognizer:self.lblProject action:@selector(lblProject_Pressed)];
	[self applyRadiusBorder:self.lblProjectBorder];
    
    self.lblProjectBorder.text = @"";
    self.lblProject.text = @"--";
    
    [self applyTapGestureRecognizer:self.lblFeature action:@selector(lblFeature_Pressed)];
	[self applyRadiusBorder:self.lblFeatureBorder];
    
    self.lblFeatureBorder.text = @"";
    self.lblFeature.text = @"--";
    
    [self applyTapGestureRecognizer:self.lblTask action:@selector(lblTask_Pressed)];
	[self applyRadiusBorder:self.lblTaskBorder];
    
    self.lblTaskBorder.text = @"";
    self.lblTask.text = @"--";
    
    [self applyTapGestureRecognizer:self.lblHours action:@selector(lblHours_Pressed)];
	[self applyRadiusBorder:self.lblHoursBorder];
    
    self.lblHoursBorder.text = @"";
    self.lblHours.text = @"--";
    
    [self applyTapGestureRecognizer:self.lblDescription action:@selector(lblDescription_Pressed)];
	[self applyRadiusBorder:self.lblDescriptionBorder];
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
    
    [self setupFormLabels];
    
    self.projects           = self.ttSettings.axianProjects;
	self.selectedProjectRow = 0;
	self.selectedFeatureRow = 0;
	self.selectedTaskRow    = 0;
	self.curHours           = 0;
	self.isValidated        = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear: animated];
	[self.navigationController setNavigationBarHidden: NO];    
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
    self.curProject = nil;
    self.curFeature = nil;
    self.curTask = nil;
    self.curDescription = nil;
    self.pickerView = nil;
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
    [_curProject release];
    [_curFeature release];
    [_curTask release];
    [_curDescription release];
    [_pickerView release];
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
	NSString *msg = nil;
    
	if(self.curProject == nil)
	{
		msg = @"Missing project details.";
	}
	else if(self.curFeature == nil)
	{
		msg = @"Missing project feature.";
	}
	else if(self.curTask == nil)
	{
		msg = @"Missing feature task.";
	}
	else if(self.curHours == 0)
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
		self.isValidated = NO;
		UIAlertView *message = [[UIAlertView alloc] initWithTitle: @"Validation Error"
                                          message: msg
                                         delegate: nil
                                cancelButtonTitle: @"OK"
                                otherButtonTitles: nil];
		
		[message show];
		[message release];
	}
	// Everything validated, post new entry data
	else 
	{
		self.isValidated = YES;
		[self postNewEntryData];
	}
}

- (void)lblProject_Pressed
{
	int tag = kProjectPickerTag;
	[self showStandardActionSheet:tag withTitle:@"Select Project"];
}

- (void)lblFeature_Pressed
{
	if(self.curProject == nil)
	{
		return;
	}
	
	int tag = kFeaturePickerTag;
	[self showStandardActionSheet:tag withTitle:@"Select Feature"];
}

- (void)lblTask_Pressed
{
	if(self.curFeature == nil)
	{
		return;
	}
	
	int tag = kTaskPickerTag;
	[self showStandardActionSheet:tag withTitle:@"Select Task"];
}

- (void)lblHours_Pressed
{ 
	if(self.curTask == nil)
	{
		// return;
	}
	// TODO: Title isn't displaying hours left, just 0.0
	float hours = self.curTask.hoursLeft;

	NSString *title = [[NSString alloc] initWithFormat: @"Hours Remaining: %2.2f", hours];
	
	UIActionSheet *actionSheet = [[[UIActionSheet alloc]
                                   initWithTitle: title 
                                   delegate: self 
                                   cancelButtonTitle: @"Cancel" 
                                   destructiveButtonTitle: nil 
                                   otherButtonTitles: @"Select", nil] autorelease];
	
	[actionSheet setTag: kHoursPickerTag];
	[actionSheet showInView: self.view.superview];
	[actionSheet setFrame: CGRectMake(0,117,320,383)];
	[title release];
}

- (void)lblDescription_Pressed
{
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
	
	if(actionSheet.tag != kHoursPickerTag)
	{
		[self setPickerViewChanges: [self.pickerView selectedRowInComponent:0]];
	}
	else 
	{
		NSTimeInterval duration = self.pickHours.countDownDuration;
		self.curHours = (float)(duration/3600.0f);
		NSString *text = [[NSString alloc] initWithFormat: @"%2.2f", self.curHours];
		self.lblHours.text = text;
		[text release];
	}
}

- (void)willPresentActionSheet:(UIActionSheet *)actionSheet 
{
	
	if(actionSheet.tag == kHoursPickerTag)
	{
		UIDatePicker *picker = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, 40, 320, 216)];
        float hours = self.curHours;
        // Hack to make the default 1 hours instead of 15 minutes
        if(hours == 0){ hours = 1; }
        
		float duration = (hours * 3600.0f);
		
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
	else 
	{
		UIPickerView *picker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 320, 26)];
		picker.showsSelectionIndicator = YES;
		picker.dataSource = self;
		picker.delegate = self;
		picker.tag = actionSheet.tag;
		
		// Only set the selected index if something has been set previously
		if(((actionSheet.tag == kProjectPickerTag)&&(self.curProject != nil))||
		   ((actionSheet.tag == kFeaturePickerTag)&&(self.curFeature != nil))||
		   ((actionSheet.tag == kTaskPickerTag)&&(self.curTask != nil)))
		{
			NSUInteger selIndex = 0;
			if(actionSheet.tag == kProjectPickerTag)
			{
				selIndex = self.selectedProjectRow;
			}
			else if(actionSheet.tag == kFeaturePickerTag)
			{
				selIndex = self.selectedFeatureRow;
			}
			else if(actionSheet.tag == kTaskPickerTag)
			{
				selIndex = self.selectedTaskRow;
			}

			[picker selectRow:selIndex inComponent:0 animated:YES];
		}
		
		[actionSheet addSubview:picker];
		
		NSArray *subviews = [actionSheet subviews];
		[[subviews objectAtIndex:1] setFrame:CGRectMake(20, 266, 280, 46)]; 
		[[subviews objectAtIndex:2] setFrame:CGRectMake(20, 317, 280, 46)];	
		
		
		self.pickerView = picker;
		
		[picker release];
	}
}


#pragma mark - PickerView Delegates

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

- (NSInteger)pickerView: (UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{	
	if(self.pickerView.tag == kProjectPickerTag)
	{
		return [self.projects count];
	}
	else if(self.pickerView.tag == kFeaturePickerTag)
	{
		return [self.curProject.projectFeatures count];
	}
	else if(self.pickerView.tag == kTaskPickerTag)
	{
        return [self.curFeature.featureTasks count];
	}
	else
	{
		return 0;
	}
}

- (NSString *)pickerView: (UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	if(self.pickerView.tag == kProjectPickerTag)
	{
		AxnProject *p = [self.projects objectAtIndex: row];
		return p.displayName;
	}
	else if(self.pickerView.tag == kFeaturePickerTag)
	{
		AxnFeature *f = [self.curProject.projectFeatures objectAtIndex: row];
		return f.featureName;
	}
	else if(self.pickerView.tag == kTaskPickerTag)
	{
		AxnTask *t = [self.curFeature.featureTasks objectAtIndex: row];
		return t.taskName;
	}
	else
	{
		NSLog(@"Unknown pickerview tag: %i", self.pickerView.tag);
		return @"--";
	}
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	// Nothing to do
	return;
}

#pragma mark - Data Set/Reset Methods

- (void)resetHours
{
	self.curHours = 0;
	self.lblHours.text = @"Select Hours";
}

- (void)resetTask
{
	self.curTask = nil;
	self.selectedTaskRow = 0;
	self.lblTask.text = @"Select Task";
	
	[self resetHours];
}

- (void)resetFeature
{
	self.curFeature = nil;
	self.selectedFeatureRow = 0;
	self.lblFeature.text = @"Select Feature";
	
	[self resetTask];
}

- (void)setPickerViewChanges: (NSInteger) row
{
    if(self.pickerView.tag == kProjectPickerTag)
	{
		// Reset previous selections if a new project was picked
		AxnProject *p = [self.projects objectAtIndex: row];
		if(self.curProject != nil)
		{
			if(self.curProject.projectId != p.projectId)
			{
				[self resetFeature];
			}
		}
		
		self.curProject = p;
		self.lblProject.text = self.curProject.displayName;
		self.selectedProjectRow = row;
	}
	else if(self.pickerView.tag == kFeaturePickerTag)
	{
		AxnFeature *f = [self.curProject.projectFeatures objectAtIndex: row];
		if(self.curFeature != nil)
		{
			if(self.curFeature.featureId != f.featureId)
			{
				[self resetTask];
			}
		}
		
		self.curFeature = f;
		self.lblFeature.text = self.curFeature.featureName;
		self.selectedFeatureRow = row;
	}
	else if(self.pickerView.tag == kTaskPickerTag)
	{
		AxnTask *t = [self.curFeature.featureTasks objectAtIndex: row];
		if(self.curTask != nil)
		{
			if(self.curTask.taskId != t.taskId)
			{
				[self resetHours];
			}
		}
		
		self.curTask = t;
		self.lblTask.text = self.curTask.taskName;
		self.selectedTaskRow = row;
	}
}

#pragma mark - HTTP Request Method

- (void)postNewEntryData 
{		
    [self showSavingEntryHud:nil];
	NSString *today = [self todayString];
	NSMutableDictionary *newEntry = [[NSMutableDictionary alloc] init];
	[newEntry setObject: [[NSNumber numberWithInt: self.curProject.projectId] retain] forKey: @"userProjectId"];
	[newEntry setObject: today forKey:@"date"];
    
	[newEntry setObject: [[NSNumber numberWithInt: self.curTask.taskId] retain] forKey: @"taskId"];
	[newEntry setObject: [[NSNumber numberWithFloat: self.curHours] retain] forKey: @"hours"];
	[newEntry setObject: self.curDescription forKey: @"notes"];
    
    NSURL *url = [NSURL URLWithString: sAddTimeUrl];
    ASIHTTPRequest *request = [self createPostRequest:url withParameters:(NSDictionary *)newEntry];
    [request setDelegate:self];
    [request setTag:kRequest_SaveNewEntryTag];
    [request startAsynchronous];
}


- (void)requestFinished:(ASIHTTPRequest *)request
{	
    [self.hud hide:YES];
	// Error object for string to json process
	NSError *error = nil;
    NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
    
	if(!jsonData)
	{
		NSLog(@"Error saving time entry: %@",[request responseString]);
        [self showAlert:@"Error" withMessage:@"Error saving entry."];
	}
	else 
	{
        NSLog(@"Response: %@", [request responseString]);
        NSDictionary *data = [jsonData objectForKey:sTimeTrackerDataDicKey];
        if(!data)
        {
            [self showAlert:@"Error" withMessage:@"Error saving time entry."];
        }
        else
        {
            NSInteger newId = [((NSString *)[data objectForKey:@"TimeEntryId"]) intValue];
            
            self.isValidated = YES;
            
            AxnTimeEntry *savedEntry = [[AxnTimeEntry alloc] init];
            savedEntry.timeEntryId = newId;
            savedEntry.projectName = self.curProject.projectName;
            savedEntry.projectAbbrv = [data objectForKey:@"ProjectAbbreviation"];
            savedEntry.projectId = self.curProject.projectId;
            savedEntry.featureName = self.curFeature.featureName;
            savedEntry.featureId = self.curFeature.featureId;
            savedEntry.taskName = self.curTask.taskName;
            savedEntry.taskId = self.curTask.taskId;
            savedEntry.calendarId = [[data objectForKey:@"CalendarId"] integerValue];
            savedEntry.isBillable = [[data objectForKey:@"IsBillable"] boolValue];
            savedEntry.isLocked = [[data objectForKey:@"Locked"] boolValue];
            savedEntry.hours = self.curHours;
            savedEntry.notes = self.curDescription;
            
            self.timeEntry = savedEntry;

            [savedEntry release];
            [[self delegate] addSavedTimeEntry:self.timeEntry];
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

- (IBAction)openPostController:(id)sender
{
    // Nothing really to do...
    return;
}

- (BOOL)postController:(TTPostController*)postController willPostText:(NSString*)text 
{
	// Done was pressed, set the label text with our changes
	self.lblDescription.text = text;
    self.curDescription = text;
	return YES;
}

- (void)postControllerDidCancel:(TTPostController*)postController 
{
	// Cancelled, do nothing
	return;
}

@end
