//
//  AxnSettingsViewController.h
//  TimeTracker
//
//  Created by Mustafa Ashurex on 1/23/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AxnBaseViewController.h"

#define sSaveReminderFormat  @"HH:mm"
#define sDisplayReminderFormat  @"hh:mm a"
#define kAlarmPickerTag (int)1

@interface AxnSettingsViewController : AxnBaseViewController
<UIActionSheetDelegate, UIPickerViewDelegate>
{
    UITextField             *txtUsername;
    UITextField             *txtPassword;
    UILabel                 *lblValidating;
    UILabel                 *lblValid;
    UILabel                 *lblInvalid;
    UILabel                 *lblReminderTime;
    UISwitch                *switchReminder;
    UIButton                *btnClearSettings;
    UIButton                *btnValidateUser;
    UIButton                *btnSaveSettings;
    UIButton                *btnSetReminder;
    UIActivityIndicatorView *actValidating;
    UIDatePicker            *datePicker;
    NSDate                  *reminderDate;
}


@property(nonatomic, retain) IBOutlet UITextField           *txtUsername;
@property(nonatomic, retain) IBOutlet UITextField           *txtPassword;
@property(nonatomic, retain) IBOutlet UILabel               *lblValidating;
@property(nonatomic, retain) IBOutlet UILabel               *lblValid;
@property(nonatomic, retain) IBOutlet UILabel               *lblInvalid;
@property(nonatomic, retain) IBOutlet UILabel               *lblReminderTime;
@property(nonatomic, retain) IBOutlet UISwitch              *switchReminder;
@property(nonatomic, retain) IBOutlet UIButton              *btnClearSettings;
@property(nonatomic, retain) IBOutlet UIButton              *btnvalidateUser;
@property(nonatomic, retain) IBOutlet UIButton              *btnSaveSettings;
@property(nonatomic, retain) IBOutlet UIButton              *btnSetReminder;
@property(nonatomic, retain) IBOutlet UIActivityIndicatorView *actValidating;
@property(nonatomic, retain) UIDatePicker *datePicker;
@property(nonatomic, retain) NSDate *reminderDate;

- (IBAction)backgroundTap:(id)sender;
- (IBAction)btnSaveSettings_Pressed:(id)sender;
- (IBAction)btnClearSettings_Pressed:(id)sender;
- (IBAction)btnSetReminder_Pressed:(id)sender;
- (IBAction)btnValidateUser_Pressed:(id)sender;
- (IBAction)switchReminder_Toggled:(id)sender;
- (BOOL)isValidSettingsInput;
- (void)showUserIsValid;
- (void)showUserIsInvalid;
- (void)hideValidatingLabels;
- (NSDate*)getDateForAlarmWithTime:(NSDate *)alarmTime forDay:(int)day;
- (void)setWeekdayUILocalNotifcations:(NSDate *)alarmTime;
@end
