//
//  FirstViewController.h
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FirstViewControllerAppDelegate.h"
#import "TutorialViewController.h"
#import "TwitterController.h"

@class SecondViewController;
@class ThirdViewController;
@class TutorialViewController;

@interface FirstViewController : UIViewController {
    TutorialViewController *tutorialViewController;
	IBOutlet SecondViewController *secondVC;
	IBOutlet ThirdViewController *thirdVC;
	IBOutlet UIViewController *viewController;
    IBOutlet UIButton *enterButton;
    IBOutlet UIButton *aboutButton;
    IBOutlet UIImageView *logo;
    IBOutlet UIButton *tweetButton;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    IBOutlet UILabel *activityLabel;
}
@property(nonatomic, retain) SecondViewController *secondVC;
@property(nonatomic, retain) ThirdViewController *thirdVC;
@property(nonatomic, retain) IBOutlet UIButton *enterButton;
@property(nonatomic, retain) IBOutlet UIButton *aboutButton;
@property(nonatomic, retain) IBOutlet UILabel *activityLabel;
@property(nonatomic, retain) IBOutlet UIButton *tweetButton;
@property (nonatomic, retain) IBOutlet TutorialViewController *tutorialViewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

-(IBAction)pressedButton:(id)sender;
-(void)receivedTick:(float)tick;
-(void)goToGallery;
-(void)showTutorial;
-(void)fadeInMenuBits;
-(void)fadeInAfterLoading;
-(IBAction)tweet;

@end