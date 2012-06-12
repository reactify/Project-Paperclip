//
//  PhotoDetailViewController.m
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCore.h"
#import "PhotoDetailViewController.h"
#import "SecondViewController.h"
#import "FirstViewController.h"
#import "Twitter/Twitter.h"
#import "PdBase.h"
#import "PhotoDetailOptionsViewController.h"
#import "SA_OAuthTwitterEngine.h"

static NSString *NameKey = @"nameKey";
static NSString *ImageKey = @"imageKey";
static NSString *DescriptionKey = @"descriptionKey";

@implementation PhotoDetailViewController

@synthesize imageView;
@synthesize moreOptionsButton;
@synthesize backButton;
@synthesize largePhoto;
@synthesize optionsButtons;
@synthesize optionsBackdrop;
@synthesize buttonArrow;
@synthesize photoSavedLabel;
@synthesize activityIndicator;
@synthesize photoDetailOptionsViewController;
@synthesize audioDesc1;
@synthesize audioDesc2;

@synthesize photoTouched;

int         drawerUp = 0;
int         sampleToSwitch;

-(void)setImageTouched:(int)numberOfImageTouched {
    photoTouched = numberOfImageTouched;
    
    // Get info of relevant photo (as sent from Gallery) from dictionary
    numberItem = [[[PSCore core]contentArray] objectAtIndex:numberOfImageTouched];
    // Create the image to live in the image view (get it from the dictionary declared above)
    largePhoto = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
    
    // For Twitter etc. in other methdoods
    photoFileAsString = [[NSString stringWithFormat:@"%@", [numberItem valueForKey:ImageKey]] retain];
    NSLog(@"photoFileAsString = %@", photoFileAsString);
    
    NSString *numberOfSampleToSwitchAsString = [photoFileAsString stringByReplacingOccurrencesOfString:@".png" withString:@""];
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * numberOfSampleToSwitchAsNumber = [f numberFromString:numberOfSampleToSwitchAsString];
    [f release];
    
    sampleToSwitch = [numberOfSampleToSwitchAsNumber intValue]-1;
    
    patchToOpen = [[NSString alloc] initWithFormat:@"_PPC-Sample-%i.pd", sampleToSwitch+1];
    
    [self performSelector:@selector(launchPdSubpatch) withObject:nil afterDelay:1.4];
//    [self launchPdSubpatch];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [photoSavedLabel setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]];
    [audioDesc1 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]];
    [audioDesc2 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]];
    
    // Subscribe to various Facebook-related notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostedSuccessfully) name:@"facebookDialogDidComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostFailed) name:@"facebookDialogDidFail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayFacebookPostCancelled) name:@"facebookDialogDidNotComplete" object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    [TestFlight passCheckpoint:@"Opened Photo Detail View"];
    
    [activityIndicator stopAnimating];
    
    [self populateImageView:largePhoto];
    
    [self setPhotoDescriptions:photoTouched];
    
    // Hide the nav bar
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    // Make sure the buttons are hidden
    moreOptionsButton.alpha = 0;
    backButton.alpha = 0;
    buttonArrow.alpha = 0;
    imageView.alpha = 0;
    audioDesc1.alpha = 0;
    audioDesc2.alpha = 0;
    _barsHidden = YES;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.4];
    [UIView setAnimationDelay:0.4];
    
    moreOptionsButton.alpha = 1;
    backButton.alpha = 1;
    buttonArrow.alpha = 1;
    imageView.alpha = 1;
    audioDesc1.alpha = 1;
    audioDesc2.alpha = 1;
    _barsHidden = NO;
    
    [UIView commitAnimations];
    
    // Hide the audio description after a 5 sec delay
    [self performSelector:@selector(hideAudioDesc) withObject:nil afterDelay:5.0];
}

- (void)setPhotoDescriptions:(int)numberOfPhotoTouched{
    // Get info of relevant photo (as sent from Gallery) from dictionary
    numberItem = [[[PSCore core]contentArray] objectAtIndex:numberOfPhotoTouched];

    // Set text of description lines
    audioDesc1.text = [numberItem valueForKey:NameKey];
    audioDesc2.text = [numberItem valueForKey:DescriptionKey];
}

- (void)populateImageView:(UIImage*)imageToShow {
    // Set the image view image
    imageView.image = imageToShow;
}

- (void)backButtonPressed {
    // Go back to Gallery
    //	[PdBase computeAudio:NO];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.4];
    
    moreOptionsButton.alpha = 0;
    backButton.alpha = 0;
    buttonArrow.alpha = 0;
    imageView.alpha = 0;
    _barsHidden = YES;
    audioDesc1.alpha = 0;
    audioDesc2.alpha = 0;
    
    [UIView commitAnimations];
    
    [PdBase sendBangToReceiver:@"stopInterfaceMusic"];
    
    [self performSelector:@selector(closePdSubpatch) withObject:nil afterDelay:1];
    [self performSelector:@selector(backToGalleryView) withObject:nil afterDelay:2];
}

- (void)backToGalleryView {
    [[self navigationController] popViewControllerAnimated:NO];
}

#pragma mark - Pd

- (void)launchPdSubpatch {
    /*
     // Get patch directory
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *pdPatchFolder = [documentsDirectory stringByAppendingPathComponent:@"/pd"];
    
    NSLog(@"Opening patch: %@", patchToOpen);
    
    // Open the patch
    [PdBase openFile:patchToOpen path:pdPatchFolder];
     */
    
    NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundlePath = [mainBundle bundlePath];

    NSLog(@"Opening patch: %@", patchToOpen);
    
    [PdBase openFile:patchToOpen path:bundlePath];
    
    // Send current hour to Pd for certain drum tracks
    NSDate *now = [NSDate date];
    NSString *dateString = [NSString stringWithFormat:@"%@",now];
    NSArray *dateArray = [dateString componentsSeparatedByString:@" "];
    NSString *timeString;
    timeString = [dateArray objectAtIndex:1];    
    NSArray *timeComponentsArray = [timeString componentsSeparatedByString:@":"];
    int hour = [[timeComponentsArray objectAtIndex:0] intValue];
    [PdBase sendFloat:hour toReceiver: @"currentTime"];
    NSLog(@"hours = %i", hour);
    
    // Send Geofence info to Pd
    int inGeofence1 = [[PSCore core] inGeofence1];
    [PdBase sendFloat:inGeofence1 toReceiver:@"inGeofence1"];
    
    // Tell main patch which sample to switch on
    [PdBase sendFloat:sampleToSwitch toReceiver: @"sampleToSwitch"];
}

- (void)closePdSubpatch{    
    NSString *patchToClose = [NSString stringWithFormat:@"pd-%@", patchToOpen];
    
    NSLog(@"Closing Pd patch: %@", patchToClose);
    
    [PdBase sendMessage:@"menuclose" withArguments:nil toReceiver:patchToClose];

    [self performSelector:@selector(startInterfaceMusic) withObject:nil afterDelay:0.2];

    [patchToOpen release];
}

- (void)startInterfaceMusic{
    [PdBase sendBangToReceiver:@"startInterfaceMusic"];    
}

#pragma mark - More options

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	[super touchesEnded:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	
    // Show/hide the buttons on touch
	if (touch.tapCount == 1) {
        if (_barsHidden == YES) {
            [self togglePhotoInfoHidden:[NSNumber numberWithInt:0]];
        }else{
            [self togglePhotoInfoHidden:[NSNumber numberWithInt:1]];
        }
	}
}

- (IBAction)moreOptionsButtonPressed:(id)sender {
    [TestFlight passCheckpoint:@"Pressed More Options button on Photo Detail View"];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.4];
    
    if (drawerUp == 0) {
        optionsButtons.transform = CGAffineTransformMakeTranslation(0, -145);
        drawerUp = 1;
        backButton.alpha = 0;
        buttonArrow.transform = CGAffineTransformMakeRotation(degreesToRadians(-180));
    }else{
        optionsButtons.transform = CGAffineTransformMakeTranslation(0, 0);
        drawerUp = 0;
        backButton.alpha = 1;
        buttonArrow.transform = CGAffineTransformMakeRotation(degreesToRadians(0));
    }
    
    [UIView commitAnimations];
}

-(void)hideAudioDesc {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.5];
    
    audioDesc2.alpha = 0;
        
    [UIView commitAnimations];
}

-(void)togglePhotoInfoHidden:(NSNumber*)hidden{
    
    if (drawerUp == 0) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.4];
        
        if ([hidden intValue] == 1) {
            moreOptionsButton.alpha = 0;
            backButton.alpha = 0;
            buttonArrow.alpha = 0;
            audioDesc1.alpha = 0;
            audioDesc2.alpha = 0;
            _barsHidden = YES;
        } else {
            moreOptionsButton.alpha = 1;
            backButton.alpha = 1;
            buttonArrow.alpha = 1;
            _barsHidden = NO;
        }
        
        [UIView commitAnimations];
    }
    
    
}

- (void)showCustomView {   
    [self.navigationController.view addSubview:self.photoDetailOptionsViewController.view];
    [self.photoDetailOptionsViewController viewWillAppear:NO];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {    
    // Was there an error?
    if (error != NULL) {
        // Show error message...
        NSLog(@"There was an error saving the image!");
        [self displayPhotoDetailConsoleMessage:@"THERE WAS AN ERROR SAVING THE IMAGE"];
    }else{
        // No errors - show message image successfully saved
        NSLog(@"Image saved successfully!");
        [self displayPhotoDetailConsoleMessage:@"PHOTO SAVED TO CAMERA ROLL"];
    }
    [activityIndicator stopAnimating];
}

#pragma mark - Twitter

- (void) tweetPhotoButtonPressed{
    [TestFlight passCheckpoint:@"Pressed Tweet button on Gallery View"];
    
    // Check if we have an active internet connection
    if ([[PSCore core] internetActive]) {
        [activityIndicator startAnimating];
        Class tweeterClass = NSClassFromString(@"TWTweetComposeViewController");
        
        if(tweeterClass != nil) {   // check for Twitter integration
            
            [self tweetPhoto];
            
        } else {
            // no Twitter integration; default to third-party Twitter framework
            [self tweetPhotoOldSkool];
        }
    }else{
        [self displayPhotoDetailConsoleMessage:@"NO INTERNET CONNECTION"];
    }
     
}

- (void) tweetPhoto{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
        // check Twitter accessibility and at least one account is setup
        if([TWTweetComposeViewController canSendTweet]) {
            TWTweetComposeViewController *tweetViewController = [[TWTweetComposeViewController alloc] init];
            
            // set initial text
            [tweetViewController setInitialText:@"Check out this photo from Project Paperclip by @nunoserrao..."];
            
            // add image
            [tweetViewController addImage:[UIImage imageNamed:photoFileAsString]];
            
            // setup completion handler
            tweetViewController.completionHandler = ^(TWTweetComposeViewControllerResult result) {
                if(result == TWTweetComposeViewControllerResultDone) {
                    // the user finished composing a tweet
                    [self displayPhotoDetailConsoleMessage:@"PHOTO TWEETED"];
                    [activityIndicator stopAnimating];
                    
                } else if(result == TWTweetComposeViewControllerResultCancelled) {
                    // the user cancelled composing a tweet
                    [self displayPhotoDetailConsoleMessage:@"CANCELLED TWEET"];
                    [activityIndicator stopAnimating];
                }
                [self dismissViewControllerAnimated:YES completion:nil];
                [activityIndicator stopAnimating];
            };
            
            [self presentViewController:tweetViewController animated:YES completion:nil];
            
//            [tweetViewController release];
//            [TWTweetComposeViewController release];
            
        } else {
            // Twitter is not accessible or the user has not setup an account
            [self displayPhotoDetailConsoleMessage:@"TWITTER NOT AVAILABLE"];
            [activityIndicator stopAnimating];
        }
    
        
    [pool release];
     
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
        NSLog(@"Sending tweet");
        [_engine sendUpdate:kTweetPrepopulatedContentFromPhotoDetail];
    }
    
//    [_engine release];
    
}

#pragma mark SA_OAuthTwitterEngineDelegate  
- (void) storeCachedTwitterOAuthData: (NSString *) data forUsername: (NSString *) username {  
    NSUserDefaults          *defaults = [NSUserDefaults standardUserDefaults];  
    
    [defaults setObject: data forKey: @"authData"];  
    [defaults synchronize];
    
    NSLog(@"Twitter is now authorised!");
	NSLog(@"Auth name (cached): %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authName"]);
	NSLog(@"Auth data (cached):%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"authData"]);
    
    [self tweetPhotoOldSkool];
}  

- (NSString *) cachedTwitterOAuthDataForUsername: (NSString *) username {  
    return [[NSUserDefaults standardUserDefaults] objectForKey: @"authData"];
} 
#pragma mark TwitterEngineDelegate  
- (void) requestSucceeded: (NSString *) requestIdentifier {  
    NSLog(@"Request %@ succeeded", requestIdentifier);
    
    [activityIndicator stopAnimating];
    
    [self displayPhotoDetailConsoleMessage:@"TWEETED PHOTO TO YOUR FEED"];

}  

- (void) requestFailed: (NSString *) requestIdentifier withError: (NSError *) error {  
    NSLog(@"Request %@ failed with error: %@", requestIdentifier, error); 
    
    [activityIndicator stopAnimating];
    
    [self displayPhotoDetailConsoleMessage:@"TWEET FAILED"];
}

#pragma mark - E-mail

- (void) emailPhoto {
    
    [TestFlight passCheckpoint:@"Pressed E-mail button on Gallery View"];
    
    NSLog(@"EMAIL PHOTO PRESSED");
    
	[activityIndicator startAnimating];
    
    [self openMailView];
}

- (void)openMailView{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    numberItem = [[[PSCore core]contentArray] objectAtIndex:photoTouched];

    NSString *photoTitle = [numberItem valueForKey:NameKey];
    
    NSString *eMailBody = [NSString stringWithFormat:@"<p>Download the app <a href='%@'>here</a>.</p><p>Visit the website here: <a href='%@'>%@</a>.</p><p><b>%@</b></p>", kAppStoreURL, kOnlineGalleryURL, kOnlineGalleryURL, photoTitle];
    
    MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
	[mailViewController setSubject:@"Project Paperclip, by Nuno Serrão"];
    [mailViewController setMessageBody:eMailBody isHTML:YES];
	[mailViewController addAttachmentData:[NSData dataWithData:UIImagePNGRepresentation([UIImage imageNamed:photoFileAsString])] mimeType:@"png" fileName:photoFileAsString];
	mailViewController.mailComposeDelegate = self;
	
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 30200
	if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
		mailViewController.modalPresentationStyle = UIModalPresentationPageSheet;
	}
#endif
	
	[self presentModalViewController:mailViewController animated:YES];
	[mailViewController release];
    
    [pool release];
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error{
	
	[self dismissModalViewControllerAnimated:YES];
	
	switch (result) {
		case MFMailComposeResultSent: 
            [self displayPhotoDetailConsoleMessage:@"PHOTO SENT SUCCESSFULLY"]; 
            break;
		case MFMailComposeResultFailed: 
            [self displayPhotoDetailConsoleMessage:@"PHOTO SENDING FAILED"];
            break;
        case MFMailComposeResultCancelled: 
            [self displayPhotoDetailConsoleMessage:@"PHOTO SENDING CANCELLED"]; 
            break;
		case MFMailComposeResultSaved: 
            [self displayPhotoDetailConsoleMessage:@"PHOTO DRAFT SAVED"];
            break;
		default:
            [self displayPhotoDetailConsoleMessage:@"PHOTO SENDING CANCELLED"];
			break;
	}
    
    [activityIndicator stopAnimating];
}

#pragma mark - Save to camera roll

- (void) savePhoto {
    
    [TestFlight passCheckpoint:@"Pressed Save photo button on Gallery View"];
        
    [self performSelectorInBackground:@selector(savePhotoToCameraRoll) withObject:nil];

    [activityIndicator startAnimating];
         
}

- (void)savePhotoToCameraRoll{
        
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    UIImageWriteToSavedPhotosAlbum(largePhoto, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
    
    [pool release];
}

#pragma mark - Facebook

- (void) sharePhoto {
    
    [TestFlight passCheckpoint:@"Pressed Share photo button on Gallery View"];
    
    if ([[PSCore core] internetActive]) {
        numberItem = [[[PSCore core]contentArray] objectAtIndex:photoTouched];
        NSString *photoTitle = [NSString stringWithFormat:@"Title: %@", [numberItem valueForKey:NameKey]];
        NSString *photoDescription = [NSString stringWithFormat:@"Soundscape: %@", [numberItem valueForKey:DescriptionKey]];        

        [[PSCore core] setDetailsToShare:photoFileAsString :photoTitle :photoDescription];
        
    }else{
        [self displayPhotoDetailConsoleMessage:@"NO INTERNET CONNECTION"];
    }
}

- (void)displayFacebookPostedSuccessfully{
    [self displayPhotoDetailConsoleMessage:@"COMPLETE"];
}

- (void)displayFacebookPostFailed{
    [self displayPhotoDetailConsoleMessage:@"FACEBOOK POST FAILED"];
}

- (void)displayFacebookPostCancelled{
    [self displayPhotoDetailConsoleMessage:@"FACEBOOK POST CANCELLED"];
}

-(void)displayPhotoDetailConsoleMessage:(NSString *)consoleMessageToDisplay{
        
    photoSavedLabel.alpha = 1;
    
    photoSavedLabel.text = consoleMessageToDisplay;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1];
    [UIView setAnimationDelay:2.2];
    
    photoSavedLabel.alpha = 0;
    
    [UIView commitAnimations];

}


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

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
