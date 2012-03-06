//
//  AxnEditTimeEntryViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/26/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "AxnTimeEntry.h"
#import "Three20/Three20.h"

#define kProjectPickerTag	(int)1
#define kFeaturePickerTag	(int)2
#define kTaskPickerTag		(int)3
#define kHoursPickerTag		(int)4

@protocol AxnEditTimeEntryViewControllerDelegate

- (void)editTimeEntry:(AxnTimeEntry *)entry;

@end

@interface AxnEditTimeEntryViewController : AxnBaseViewController
<UIActionSheetDelegate, MBProgressHUDDelegate, TTPostControllerDelegate>
{
    id <AxnEditTimeEntryViewControllerDelegate> delegate;
    
	UILabel *lblProject;
    UILabel *lblProjectBorder;
    
	UILabel *lblTask;
    // UILabel *lblTaskBorder;
    
	UILabel *lblFeature;
    // UILabel *lblFeatureBorder;
    
	UILabel *lblDescription;
    UILabel *lblDescriptionBorder;
    
	UILabel *lblHours;
    // UILabel *lblHoursBorder;
    
    NSArray *projects;
	
	AxnTimeEntry *timeEntry;    
    UIDatePicker *pickHours;
	BOOL        wereChangesMade;
    float       curHours;
    NSString    *curDescription;
    BOOL keyboardIsShown;
}

@property(nonatomic, assign) id<AxnEditTimeEntryViewControllerDelegate> delegate; 

@property(nonatomic, retain) AxnTimeEntry     *timeEntry;
@property(nonatomic, assign) BOOL             wereChangesMade;
@property(nonatomic, assign) BOOL             keyboardIsShown;
@property(nonatomic, assign) float            curHours;
@property(nonatomic, retain) NSString         *curDescription;

@property(nonatomic, retain) IBOutlet UILabel *lblProject;
@property(nonatomic, retain) IBOutlet UILabel *lblProjectBorder;
@property(nonatomic, retain) IBOutlet UILabel *lblTask;
// @property(nonatomic, retain) IBOutlet UILabel *lblTaskBorder;
@property(nonatomic, retain) IBOutlet UILabel *lblFeature;
// @property(nonatomic, retain) IBOutlet UILabel *lblFeatureBorder;
@property(nonatomic, retain) IBOutlet UILabel *lblDescription;
@property(nonatomic, retain) IBOutlet UILabel *lblDescriptionBorder;
@property(nonatomic, retain) IBOutlet UILabel *lblHours;
// @property(nonatomic, retain) IBOutlet UILabel *lblHoursBorder;

@property(nonatomic, retain) UIDatePicker *pickHours;


-(void)postNewEntryData;
-(void)showStandardActionSheet:(NSInteger)tag withTitle:(NSString *)title;
-(IBAction)openPostController:(id)sender;
-(IBAction)showSavingEntryHud:(id)sender;

@end
