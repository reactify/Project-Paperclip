//
//  TwitterController.m
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TwitterController.h"
#import "SA_OAuthTwitterEngine.h"
#import "PSCore.h"

static TwitterController *twitterController;

@implementation TwitterController

+(void)initialize
{
	static BOOL initialised = NO;
	if (!initialised)
	{
		initialised = YES;
		twitterController = [[TwitterController alloc] init];
	}
    
}

+(TwitterController *)twitterController {
	@synchronized(self)
	{
		if (twitterController == NULL) twitterController = [[self alloc] init];
	}
	return twitterController;
}

-(void)twitterTestMethod{
    NSLog(@"Twitter Test Method has run");
}

-(void)authorizeTwitter {
    if(!_engine){
        NSLog(@"There is no engine");
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
        _engine.consumerKey    = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;  
    }
    
    if(![_engine isAuthorized]){
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
        
        NSLog(@"Controller is: %@", controller);
        
        if (controller){
            UIViewController* vc = [[[UIViewController alloc] init] autorelease];
            UIWindow* keyWindow = [[UIApplication sharedApplication] keyWindow];
            UIView* topView = [[keyWindow subviews] objectAtIndex:[[keyWindow subviews] count] -1];
            vc.view = topView;
            
            [vc presentModalViewController: controller animated: YES];
            
            [keyWindow makeKeyAndVisible];
            
            NSLog(@"Key window subviews: %@", [keyWindow subviews]);
            NSLog(@"Key window subviews count: %i", [[keyWindow subviews] count]);
            NSLog(@"Logging in to Twitter");
        }
    }else{
        [self logoutFromTwitter];
        NSLog(@"Trying to log-out from Twitter");
        //        [_engine sendUpdate:kTweetPrepopulatedContentFromAbout];
    }
}
- (IBAction)updateTwitter:(id)sender{
    
}

-(void)logoutFromTwitter {
    
	NSLog(@"Logging out from Twitter");
	[_engine clearAccessToken];
	[_engine clearsCookies];
	[_engine setClearsCookies:YES];
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:@"authData"];
	[[NSUserDefaults standardUserDefaults]removeObjectForKey:@"authName"];
    
	NSLog(@"Auth name: %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authName"]);
	NSLog(@"Auth data: %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]);
    
	[_engine release];
	_engine=nil; 
}

#pragma mark SA_OAuthTwitterEngineDelegate  
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {  
    NSUserDefaults          *defaults = [NSUserDefaults standardUserDefaults];  
    
    [defaults setObject: data forKey: @"authData"];  
    [defaults synchronize];
    
    NSLog(@"Twitter is now authorised!");
	NSLog(@"Auth name (cached): %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authName"]);
	NSLog(@"Auth data (cached):%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]);
    
}  

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {  
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
} 

#pragma mark TwitterEngineDelegate  
- (void) requestSucceeded: (NSString *) requestIdentifier {  
    NSLog(@"Request %@ succeeded", requestIdentifier);
    
}  

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {  
    NSLog(@"Request %@ failed with error: %@", requestIdentifier, error);  
}  
@end
