//
//  ThirdViewController.m
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import "ThirdViewController.h"
#import "Twitter/Twitter.h"
#import "FirstViewControllerAppDelegate.h"
#import "TutorialViewController.h"
#import "SA_OAuthTwitterEngine.h"
#import "PSCore.h"

@implementation ThirdViewController

@synthesize tutorialViewController;
@synthesize tweetButton;
@synthesize facebookButton;
@synthesize consoleMessagesLabel;

- (void)viewDidLoad {
    [aboutText setFont:[UIFont fontWithName:@"Helvetica Neue LT Com" size:14.0]];
    [consoleMessagesLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]];
    
    // Check which Twitter button to display
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]){
        [tweetButton setImage:[UIImage imageNamed:@"about-tweet-logout.png"] forState:UIControlStateNormal];
        NSLog(@"About viewWillAppear says there is auth data");
    }else{        
        [tweetButton setImage:[UIImage imageNamed:@"about-tweet.png"] forState:UIControlStateNormal];
        NSLog(@"About viewWillAppear says there is NO auth data");
    }
    
    // Check which Facebook button to display
    if([[NSUserDefaults standardUserDefaults]valueForKey:@"FBAccessTokenKey"]){
        [facebookButton setImage:[UIImage imageNamed:@"about-facebook-logout.png"] forState:UIControlStateNormal];
        NSLog(@"About viewWillAppear says there is facebook login data");
        NSLog(@"Facebook button is: %@", facebookButton.imageView);
    }else{        
        [facebookButton setImage:[UIImage imageNamed:@"about-facebook.png"] forState:UIControlStateNormal];
        NSLog(@"About viewWillAppear says there is NO facebook login data");
        NSLog(@"Facebook button is: %@", facebookButton.imageView);
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFacebookButtonToLogin) name:@"facebookDidLogout" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeFacebookButtonToLogout) name:@"facebookDidLogin" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostedSuccessfully) name:@"facebookDialogDidComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostFailed) name:@"facebookDialogDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostCancelled) name:@"facebookDialogDidNotComplete" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    [TestFlight passCheckpoint:@"Opened About View"];
    
    
    backButton.alpha = 0.0;
    appStoreButton.alpha = 0.0;
    infoButton.alpha = 0.0;
    tweetButton.alpha = 0.0;
    facebookButton.alpha = 0.0;
    aboutText.alpha = 0.0;
    consoleMessagesLabel.alpha = 0.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelay:0.3];
    
    backButton.alpha = 1.0;
    appStoreButton.alpha = 1.0;
    infoButton.alpha = 1.0;
    tweetButton.alpha = 1.0;
    facebookButton.alpha = 1.0;
    aboutText.alpha = 1.0;
    
    [UIView commitAnimations];
}

- (void)displayFacebookPostedSuccessfully{
    [self displayConsoleMessage:@"COMPLETE"];
}

- (void)displayFacebookPostFailed{
    [self displayConsoleMessage:@"FACEBOOK POST FAILED"];
}

- (void)displayFacebookPostCancelled{
    [self displayConsoleMessage:@"FACEBOOK POST CANCELLED"];
}

- (IBAction)displayConsoleMessage:(NSString *)consoleMessageToDisplay{
    NSLog(@"Displaying console message: %@", consoleMessageToDisplay);
    
    consoleMessagesLabel.alpha = 1;
    
    consoleMessagesLabel.text = consoleMessageToDisplay;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelay:2.2];
    
    consoleMessagesLabel.alpha = 0;
    
    [UIView commitAnimations];
}

-(IBAction)pressedButton {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    
    backButton.alpha = 0.0;
    appStoreButton.alpha = 0.0;
    infoButton.alpha = 0.0;
    tweetButton.alpha = 0.0;
    facebookButton.alpha = 0.0;
    aboutText.alpha = 0.0;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(backToMainMenu) withObject:nil afterDelay:0.6];
}

- (void)backToMainMenu {
    // Go back to the main menu
	[[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark -
#pragma mark Rate

- (IBAction)pressedRateInAppStoreButton{
    
    [TestFlight passCheckpoint:@"Pressed Rate In App Store Button on About View"];
    
    NSString *str = kAppStoreURL;
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString:str]];
}

#pragma mark -
#pragma mark Info

- (void)pressedInfoButton{    
    [TestFlight passCheckpoint:@"Pressed Info Button on About View"];
    [self.navigationController.view addSubview:self.tutorialViewController.view];
    [self.tutorialViewController viewWillAppear:NO];
}

#pragma mark -
#pragma mark Facebook

- (IBAction)pressedFacebookButton {    
    if ([[PSCore core] internetActive]) { 
        
        if ([[NSUserDefaults standardUserDefaults]valueForKey:@"FBAccessTokenKey"]) {
            NSLog(@"Facebook is logged in, so we're going to log out");
            [[PSCore core] facebookLogout];
        }else{
            NSLog(@"Facebook is logged out, so we're going to log in and post something");
            [[PSCore core] setDetailsToShare:@"4.png":@"Project Paperclip":@"Photos and reactive soundscapes from Nuno Serrão"];
        }
        
    }else{
        [self displayConsoleMessage:@"NO INTERNET CONNECTION"];
    }
    
    [TestFlight passCheckpoint:@"Pressed Facebook Button on About View"];
    
}

- (IBAction)logoutFromFacebook{
    [[PSCore core] facebookLogout];
    [facebookButton setImage:[UIImage imageNamed:@"about-facebook.png"] forState:UIControlStateNormal];
}

- (IBAction)changeFacebookButtonToLogin{
    [self displayConsoleMessage:@"LOGGED OUT OF FACEBOOK"];
    NSLog(@"Changing Facebook button to login");
    [facebookButton setImage:[UIImage imageNamed:@"about-facebook.png"] forState:UIControlStateNormal];
}

- (IBAction)changeFacebookButtonToLogout{
    NSLog(@"Changing Facebook button to logout");
    [facebookButton setImage:[UIImage imageNamed:@"about-facebook-logout.png"] forState:UIControlStateNormal];
}

#pragma mark -
#pragma mark Twitter


- (IBAction)pressedTweetButton {
//    [activityIndicator startAnimating];
    
    
    
    [TestFlight passCheckpoint:@"Pressed Tweet button on Gallery View"];
    
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    
    if(tweeterClass != nil) {   // check for Twitter integration
        
        [self tweetPhoto];
        
    } else {
        // no Twitter integration; default to third-party Twitter framework
        [self tweetPhotoOldSkool];
    }
     
    [self displayConsoleMessage:@"NO INTERNET CONNECTION"];
}

- (void) tweetPhoto{
    
     
    Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
    
    [TestFlight passCheckpoint:@"Pressed Twitter Button on About View"];
    
    if ([[PSCore core] internetActive]) {
        if(tweeterClass != nil) {   // check for Twitter integration
            
            // check Twitter accessibility and at least one account is setup
            if([TWTweetComposeViewController canSendTweet]) {
                TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
                
                // set initial text
                [tweetViewController setInitialText:@"Check out Project Paperclip from @nunoserrao..."];
                
                // setup completion handler
                tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                    if(result == TWTweetComposeViewControllerResultDone) {
                        // the user finished composing a tweet
                    } else if(result == TWTweetComposeViewControllerResultCancelled) {
                        // the user cancelled composing a tweet
                    }
                    [self dismissViewControllerAnimated:YES completion:nil];
                };
                
                [self presentViewController:tweetViewController animated:YES completion:nil];
                
                [tweetViewController release];
                
            } else {
                [self displayConsoleMessage:@"TWITTER UNAVAILABLE"];
                NSLog(@"Twitter not accessible");
            }
        }
     }else{
     [self displayConsoleMessage:@"NO INTERNET CONNECTION"];
    }

}
     
- (void) tweetPhotoOldSkool{
    if(!_engine){
        NSLog(@"There is no engine");
        _engine = [[SA_OAuthTwitterEngine alloc] initOAuthWithDelegate:self];  
        _engine.consumerKey    = kOAuthConsumerKey;
        _engine.consumerSecret = kOAuthConsumerSecret;  
    }
    
    if(![_engine isAuthorized]){
        UIViewController *controller = [SA_OAuthTwitterController controllerToEnterCredentialsWithTwitterEngine:_engine delegate:self];  
        
        if (controller){
            [self presentModalViewController: controller animated: YES];
            NSLog(@"Logging in to Twitter");
        }
    }else{
        [self logoutFromTwitter];
        NSLog(@"Trying to log-out from Twitter");
//        [_engine sendUpdate:kTweetPrepopulatedContentFromAbout];
    }
}

- (IBAction)updateTwitter:(id)sender{
//    NSString *testTweet = [NSString stringWithFormat:@"BOOM BAH"];
//    [_engine sendUpdate:testTweet];
    
    [tweetButton setImage:[UIImage imageNamed:@"about-tweet-logout.png"] forState:UIControlStateNormal];
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
    
    [tweetButton setImage:[UIImage imageNamed:@"about-tweet.png"] forState:UIControlStateNormal];
    [self displayConsoleMessage:@"LOGGED OUT OF TWITTER"];
    
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
    [tweetButton setImage:[UIImage imageNamed:@"about-tweet-logout.png"] forState:UIControlStateNormal];
    
    [self displayConsoleMessage:@"LOGGED IN TO TWITTER"];
    
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

- (void)dealloc {
    [_engine release];  
    [tweetTextField release];  
}

@end