//
//  PhotoDetailViewController.h
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 20/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoDetailOptionsViewController.h"
#import "SA_OAuthTwitterController.h" 

#define degreesToRadians(x) (M_PI * (x) /180.0)

@class PhotoDetailOptionsViewController;
@class SA_OAuthTwitterEngine; 

@interface PhotoDetailViewController : UIViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, SA_OAuthTwitterControllerDelegate> {
    PhotoDetailOptionsViewController *photoDetailOptionsViewController;
//    UIView *view;
    IBOutlet UIImageView *imageView;
    NSDictionary* contentArray;
	BOOL _barsHidden;
    UIView *_popoverOverlay; 
    IBOutlet UIButton *moreOptionsButton;
    IBOutlet UIButton *backButton;
    UIImage *largePhoto;
    NSString* photoFileAsString;
    IBOutlet UIView *optionsButtons;
    IBOutlet UIView *optionsBackdrop;
    IBOutlet UIImageView *buttonArrow;
    NSDictionary *numberItem;
    int photoTouched;
    IBOutlet UILabel *photoSavedLabel;
    IBOutlet UILabel *audioDesc1;
    IBOutlet UILabel *audioDesc2;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    SA_OAuthTwitterEngine    *_engine;
    NSString* patchToOpen;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *moreOptionsButton;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIImageView *buttonArrow;
@property (nonatomic, retain) UIImage *largePhoto;
@property (nonatomic, retain) IBOutlet UIView *optionsButtons;
@property (nonatomic, retain) IBOutlet UIView *optionsBackdrop;
@property (nonatomic, retain) IBOutlet UILabel *photoSavedLabel;
@property (nonatomic, retain) IBOutlet UILabel *audioDesc1;
@property (nonatomic, retain) IBOutlet UILabel *audioDesc2;

@property (nonatomic, retain) IBOutlet PhotoDetailOptionsViewController *photoDetailOptionsViewController;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;

@property int photoTouched;

-(void)populateImageView:(UIImage*)imageToShow;
-(void)launchPdSubpatch;
-(void)closePdSubpatch;
-(void)togglePhotoInfoHidden:(NSNumber*)hidden;
-(IBAction)moreOptionsButtonPressed:(id)sender;
-(IBAction)backButtonPressed;
-(void)showCustomView;
-(IBAction)tweetPhotoButtonPressed;
-(void)tweetPhoto;
-(void)tweetPhotoOldSkool;
-(IBAction)sharePhoto;
-(IBAction)emailPhoto;
-(IBAction)savePhoto;
-(void)startInterfaceMusic;
-(void)switchOffPd;
-(void)switchOnPd;
-(void)setImageTouched:(int)numberOfImageTouched;
-(void)savePhotoToCameraRoll;
-(void)displayPhotoDetailConsoleMessage:(NSString *)consoleMessageToDisplay;
-(void)displayFacebookPostedSuccessfully;
-(void)displayFacebookPostFailed;
-(void)displayFacebookPostCancelled;
-(void)openMailView;
-(void)hideAudioDesc;
-(void)setPhotoDescriptions:(int)numberOfPhotoTouched;


@end
