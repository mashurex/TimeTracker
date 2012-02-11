//
//  AxianViewController.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 11/4/11.
//  Copyright 2011 Axian, Inc. All rights reserved.
//

#import "AxnBaseViewController.h"
#import "MBProgressHUD.h"
#import "TTSettings.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "AxnProject.h"
#import "AxnTask.h"
#import "AxnFeature.h"
#import "AxnAppDelegate.h"


@implementation AxnBaseViewController

@synthesize ttSettings      = _ttSettings;
@synthesize comingFromLogin = _comingFromLogin;
@synthesize hud             = _hud;

- (void)viewDidLoad
{
	[super viewDidLoad];
	AxnAppDelegate *delegate = (AxnAppDelegate *)[[UIApplication sharedApplication] delegate];
	self.ttSettings = delegate.settings;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
}


- (void)dealloc 
{
    [super dealloc];
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

- (void)showAlert:(NSString *)title withMessage:(NSString *)message
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
                                      message: message
                                     delegate: nil
                            cancelButtonTitle: @"OK"
                            otherButtonTitles: nil];
    
    [alert show];
    [alert release];    
}

#pragma mark - HUD methods

- (void)showHud:(UIView *)view withLabel:(NSString *)text
{
    // NSLog(@"Showing hud with label: %@", text);
    self.hud = [[MBProgressHUD alloc] initWithView:view];
	self.hud.delegate = self;
	self.hud.labelText = text;
	self.hud.removeFromSuperViewOnHide = YES;    
    [view addSubview: hud];
	[self.hud show: YES];
}

- (void)hideHud:(NSTimeInterval)delay
{
    if(!self.hud){ return; }
    [self.hud hide:YES afterDelay:delay];
}

/*
- (void)hudWasHidden 
{   
    if(!self.hud){ return; }
    NSLog(@"Hud was hidden...");
	// Remove HUD from screen when the HUD was hidden
	if(self.hud.superview != nil)
    {
        [self.hud removeFromSuperview];
    }
	[self.hud release];
}
*/

- (void)showSuccessfullyCompletedHud:(NSString *)labelText
{
    self.hud.customView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] autorelease];
    self.hud.mode = MBProgressHUDModeCustomView;
    self.hud.labelText = labelText;
    [self.hud hide:YES afterDelay:0.33];
}


# pragma mark - HTTP request handlers and convenience methods

- (ASIHTTPRequest *)createPostRequest:(NSURL *)url withParameters:(NSDictionary *)params
{
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	NSString *json = [jsonWriter stringWithObject:params];
	NSMutableData *jsonData = (NSMutableData *)[json dataUsingEncoding:NSUTF8StringEncoding];
	
	// NSLog(@"createPostRequest request string: %@ (length %i)",json,[json length]);
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:@"POST"];
	[request setPostBody:jsonData];
	[request addRequestHeader:@"Content-Type" value:@"application/json"];
	[request addRequestHeader:@"charset" value:@"utf-8"];
	[request setTimeOutSeconds:kDefaultRequestTimeout];
	
	[jsonWriter release];
	return request;
}

- (ASIHTTPRequest *)createFetchProjectsRequest
{		
	NSString *today = [self todayString];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:today, @"date", nil];
    
	// Create an asynchronous form post to test the login
	NSURL *url = [NSURL URLWithString:sGetProjectsUrl];
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:params];
	[request setTimeOutSeconds:kDefaultRequestTimeout];
    [request setTag:kRequest_FetchProjectsTag];
	return request;
}

- (ASIHTTPRequest *)createLoginRequest:(NSString *)username withPassword:(NSString *)password 
{
	NSURL *url = [NSURL URLWithString:sAuthenticateUrl];
	
	NSMutableDictionary *dictRequestParams = [NSMutableDictionary 
											  dictionaryWithObjectsAndKeys:
											  username, sUsernameDicKey,
											  password, sPasswordDicKey,
											  nil];
	
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:dictRequestParams];
	[request setTag:kRequest_AuthenticateTag];
    return request;
}


- (NSArray *)fetchFeatures:(NSInteger)projectId
{
	// NSLog(@"Fetching features for project: %i", projectId);
	
	NSString *today = [self todayString];
	
	NSMutableDictionary *dictRequestParams = [[NSMutableDictionary alloc] init];
	[dictRequestParams setObject:today forKey:@"date"];
	[dictRequestParams setObject:[NSNumber numberWithInteger:projectId] forKey:@"userProjectId"];
	
	NSURL *url = [NSURL URLWithString:sGetFeaturesUrl];
	
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:dictRequestParams];
	[request startSynchronous];
	
	if([request error] != nil)
	{
		NSLog(@"Error fetching features for project %i: %@",projectId,
              [[request error] localizedDescription]);
		return nil;
	}
	else 
	{
		NSError *error = nil;
		SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
		// Response string from the HTTP request
		NSString *responseString = [request responseString];		
		// Json data as a dictionary
		NSDictionary *responseData = [jsonParser objectWithString:responseString error:&error];
		
		// NSLog(@"Feature response: %@",responseString);
		
		NSMutableArray *featuresArray = [[NSMutableArray alloc] init];
		// Get all the entry collections
		NSArray *entries = [responseData objectForKey:sTimeTrackerDataDicKey];
		// Iterate through them and initialize each TimeEntry object
		int i;
		for(i = 0; i < [entries count]; i++)
		{
			NSDictionary *entryDic = [entries objectAtIndex:i];
			if([[entryDic objectForKey:@"Key"] intValue] != 0)
			{
				AxnFeature *entry = [[AxnFeature alloc] initWithDictionary:entryDic];
				[featuresArray addObject:entry];
				[entry release];		
			}
		}
		
		// NSLog(@"Found %i features for project %i", [featuresArray count], projectId);
		
		return featuresArray;
	}
}

- (NSArray *)fetchTasks:(NSInteger)projectId forFeature:(NSInteger)featureId
{
	NSString *today = [self todayString];
	
	NSMutableDictionary *dictRequestParams = [[NSMutableDictionary alloc] init];
	[dictRequestParams setObject:today forKey:@"date"];
	[dictRequestParams setObject:[NSNumber numberWithInteger:projectId] forKey:@"userProjectId"];
	[dictRequestParams setObject:[NSNumber numberWithInteger:featureId] forKey:@"featureId"];
	
	NSURL *url = [NSURL URLWithString:sGetTasksUrl];
	
	ASIHTTPRequest *request = [self createPostRequest:url withParameters:dictRequestParams];
	[request startSynchronous];
	
	if([request error] != nil)
	{
		NSLog(@"Error fetching tasks for project %i: %@",projectId,
              [[request error] localizedDescription]);
		return nil;
	}
	else 
	{
		NSError *error = nil;
		SBJsonParser *jsonParser = [[SBJsonParser new] autorelease];
		// Response string from the HTTP request
		NSString *responseString = [request responseString];		
		// Json data as a dictionary
		NSDictionary *responseData = [jsonParser objectWithString:responseString error:&error];
		
		// NSLog(@"Task response: %@", responseString);
		
		NSMutableArray *tasksArray = [[NSMutableArray alloc] init];
		// Get all the entry collections
		NSArray *entries = [responseData objectForKey:sTimeTrackerDataDicKey];
		// Iterate through them and initialize each TimeEntry object
		int i;
		for(i = 0; i < [entries count]; i++)
		{
			NSDictionary *entryDic = [entries objectAtIndex:i];
			if([[entryDic objectForKey:@"Key"] intValue] != 0)
			{
				AxnTask *entry = [[AxnTask alloc] init];
				entry.taskId = [[entryDic objectForKey:@"Key"] intValue];
				entry.taskName = [entryDic objectForKey:@"Value"];
				
				[tasksArray addObject:entry];
				[entry release];		
			}
		}
		
		//NSLog(@"Found %i tasks for project (%i) feature (%i)", 
        //      [tasksArray count], projectId, featureId);
		
		return tasksArray;
	}
}

-(NSDictionary *)getJsonDataFromResponseString:(NSString *)responseString error:(NSError **)error
{
    if([responseString isEqualToString:sNullDataResponse])
    {
        return nil;
    }
    
	// Json parser
	SBJsonParser *json = [[SBJsonParser new] autorelease];
	// NSLog(@"Parsing response: %@ (length %d)", responseString, [responseString length]);
	// Json data as a dictionary
	NSDictionary *jsonData = [json objectWithString:responseString error:error];	
	return jsonData;
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    if(!request){ return; }
	NSError *error = [request error];

    if(![self requestFailedOnAuth:request])
    {
        NSLog(@"HTTP request failed: %@", [request responseString]);
        if(error){ NSLog(@"Error: %@", [error localizedDescription]); }
    }
    [self hideHud:0.0];
}

- (BOOL)requestFailedOnAuth:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    if(!error){ return false; }
    
    NSString *desc = [error localizedDescription];
    if([desc isEqualToString:sAuthenticationNeeded])
    {
        return true;
    }
    return false;
}


/**
 * Perform the actions necessary to segue to the login form
 */
- (void)showLoginForm:(NSString *)segueIdentifier sender:(id)sender
{
    self.comingFromLogin = YES;
    [self performSegueWithIdentifier:segueIdentifier sender:sender];
}


@end
