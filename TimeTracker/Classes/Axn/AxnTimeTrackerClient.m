//
//  AxnTimeTrackerClient.m
//  TimeTracker
//
//  Created by Mustafa Ashurex on 2/23/12.
//  Copyright (c) 2012 Axian, Inc. All rights reserved.
//

/***********************************
 * Not used yet
 ***********************************/

#import "AxnTimeTrackerClient.h"
#import "ASIHTTPRequest.h"
#import "SBJson.h"
#import "AxnProject.h"
#import "AxnTask.h"
#import "AxnFeature.h"

@implementation AxnTimeTrackerClient

@synthesize delegate = _delegate;

- (void)dealloc {
    self.delegate = nil;
    [super dealloc];
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

- (void)processLoginHttpRequest:(ASIHTTPRequest *)request
{
    NSError *error;
    NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
    BOOL isValid = [[jsonData objectForKey:sDataDicKey] boolValue];
	if(isValid)
	{
		// TODO: Successful login
	}
    else
    {
        // TODO: Unsuccessful logi
    }
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
	NSError *error;
	NSDictionary *jsonData = [self getJsonDataFromResponseString:[request responseString] error:&error];
    
    if(!jsonData){
        switch(request.tag)
        {
            case kRequest_AuthenticateTag:
                [self.delegate authenticationRequestFailed:request];
                break;
            default:
                break;
        }
        return;
    }
    
    switch(request.tag)
    {
        case kRequest_AuthenticateTag:
            [self processLoginHttpRequest:request];
            break;
        default:
            break;
    }
    
    /*
	BOOL isValid = [[jsonData objectForKey:sTimeTrackerDataDicKey] boolValue];
	if(isValid)
	{
		
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
     */
}

# pragma mark - HTTP request handlers and convenience methods

- (ASIHTTPRequest *)createPostRequest:(NSURL *)url withParameters:(NSDictionary *)params
{
	SBJsonWriter *jsonWriter = [[SBJsonWriter alloc] init];
	NSString *json = [jsonWriter stringWithObject:params];
	NSMutableData *jsonData = (NSMutableData *)[json dataUsingEncoding:NSUTF8StringEncoding];
	
	ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:url];
	[request setRequestMethod:sRequestPost];
	[request setPostBody:jsonData];
	[request addRequestHeader:@"Content-Type" value:sContentTypeJson];
	[request addRequestHeader:@"charset" value:sUTF8];
	[request setTimeOutSeconds:kDefaultRequestTimeout];
	
	[jsonWriter release];
	return request;
}

- (ASIHTTPRequest *)createFetchProjectsRequest
{		
	NSString *today = [self todayString];
	NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:today, @"date", nil];
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
		NSArray *entries = [responseData objectForKey:sDataDicKey];
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
		NSArray *entries = [responseData objectForKey:sDataDicKey];
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

@end
