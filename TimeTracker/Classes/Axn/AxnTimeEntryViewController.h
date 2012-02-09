//
//  AxnTimeEntryViewController.h
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

@protocol AxnTimeEntryViewControllerDelegate

- (void)addSavedTimeEntry:(AxnTimeEntry *)entry;

@end

@interface AxnTimeEntryViewController : AxnBaseViewController
<UIActionSheetDelegate, UIPickerViewDelegate, UIPickerViewDataSource, MBProgressHUDDelegate, TTPostControllerDelegate>
{
    id <AxnTimeEntryViewControllerDelegate> delegate;
    
	UILabel *lblProject;
    UILabel *lblProjectBorder;
    
	UILabel *lblTask;
    UILabel *lblTaskBorder;
    
	UILabel *lblFeature;
    UILabel *lblFeatureBorder;
    
	UILabel *lblDescription;
    UILabel *lblDescriptionBorder;
    
	UILabel *lblHours;
    UILabel *lblHoursBorder;
    
    NSArray *projects;
	
	AxnTimeEntry *entry;
    AxnProject *curProject;
    AxnFeature *curFeature;
    AxnTask *curTask;
    float curHours;
    NSString *curDescription;
    
	UIPickerView *pickerView;
    UIDatePicker *pickHours;
    
	BOOL wereChangesMade;
    BOOL isValidated;
    
    NSUInteger selectedProjectRow;
    NSUInteger selectedFeatureRow;
    NSUInteger selectedTaskRow;
}

@property(nonatomic, assign) id<AxnTimeEntryViewControllerDelegate> delegate; 

@property(nonatomic, retain) NSArray        *projects;
@property(nonatomic, retain) AxnTimeEntry   *timeEntry;
@property(nonatomic, retain) AxnProject     *curProject;
@property(nonatomic, retain) AxnFeature     *curFeature;
@property(nonatomic, retain) AxnTask        *curTask;
@property(nonatomic, assign) float          curHours;
@property(nonatomic, retain) NSString       *curDescription;

@property(nonatomic, assign) BOOL           wereChangesMade;
@property(nonatomic, assign) BOOL           isValidated;

@property(nonatomic, retain) IBOutlet UILabel *lblProject;
@property(nonatomic, retain) IBOutlet UILabel *lblProjectBorder;

@property(nonatomic, retain) IBOutlet UILabel *lblTask;
@property(nonatomic, retain) IBOutlet UILabel *lblTaskBorder;

@property(nonatomic, retain) IBOutlet UILabel *lblFeature;
@property(nonatomic, retain) IBOutlet UILabel *lblFeatureBorder;

@property(nonatomic, retain) IBOutlet UILabel *lblDescription;
@property(nonatomic, retain) IBOutlet UILabel *lblDescriptionBorder;

@property(nonatomic, retain) IBOutlet UILabel *lblHours;
@property(nonatomic, retain) IBOutlet UILabel *lblHoursBorder;

@property(nonatomic, retain) UIDatePicker *pickHours;
@property(nonatomic, retain) UIPickerView *pickerView;

@property (nonatomic, assign) NSUInteger selectedProjectRow;
@property (nonatomic, assign) NSUInteger selectedFeatureRow;
@property (nonatomic, assign) NSUInteger selectedTaskRow;

-(IBAction)btnSave_Pressed:(id)sender;

-(void)postNewEntryData;

-(void)lblProject_Pressed;
-(void)lblFeature_Pressed;
-(void)lblTask_Pressed;
-(void)lblHours_Pressed;
-(void)lblDescription_Pressed;

-(void)resetHours;
-(void)resetTask;
-(void)resetFeature;

-(void)setPickerViewChanges:(NSInteger)row;
-(void)showStandardActionSheet:(NSInteger)tag withTitle:(NSString *)title;
-(IBAction)showSavingEntryHud:(id)sender;

@end
