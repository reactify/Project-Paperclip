//
//  ThirdViewController.h
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import <UIKit/UIKit.h>
#import "TutorialViewController.h"
#import "SA_OAuthTwitterController.h"  

//#define myAppDelegate (FirstViewControllerAppDelegate *) [[UIApplication sharedApplication] delegate]
@class TutorialViewController;
@class SA_OAuthTwitterEngine; 

@interface ThirdViewController : UIViewController <MFMailComposeViewControllerDelegate, UITextFieldDelegate, SA_OAuthTwitterControllerDelegate> {
    
    TutorialViewController *tutorialViewController;
    IBOutlet UIButton *backButton;
    IBOutlet UIButton *appStoreButton;
    IBOutlet UIButton *infoButton;
    IBOutlet UIButton *tweetButton;
    IBOutlet UIButton *facebookButton;
    IBOutlet UITextView *aboutText;
    IBOutlet UILabel *consoleMessagesLabel;
    
    IBOutlet UITextField     *tweetTextField;    
    SA_OAuthTwitterEngine    *_engine;
}

@property (nonatomic, retain) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic, retain) IBOutlet UIButton *tweetButton;
@property (nonatomic, retain) IBOutlet UIButton *facebookButton;
@property (nonatomic, retain) IBOutlet UILabel *consoleMessagesLabel;

- (IBAction)updateTwitter:(id)sender;  
- (IBAction)pressedRateInAppStoreButton;
- (IBAction)pressedInfoButton;
- (IBAction)pressedTweetButton;
- (IBAction)pressedFacebookButton;
- (IBAction)displayConsoleMessage:(NSString *)consoleMessageToDisplay;
- (void)displayFacebookPostedSuccessfully;
- (void)displayFacebookPostFailed;
- (void)displayFacebookPostCancelled;
- (void)logoutFromTwitter;
- (void)tweetPhotoOldSkool;
- (void)tweetPhoto;
- (IBAction)logoutFromFacebook;
- (IBAction)changeFacebookButtonToLogin;
- (IBAction)changeFacebookButtonToLogout;
@end
