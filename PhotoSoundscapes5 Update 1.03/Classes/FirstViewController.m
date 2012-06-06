//
//  FirstViewController.m
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "PhotoDetailViewController.h"
#import "FirstViewControllerAppDelegate.h"
#import "PdBase.h"
#import "PdAudio.h"
#import "TutorialViewController.h"
#import "SA_OAuthTwitterController.h"
#import "TwitterController.h"
#define kMenuBitsFadeTime 0.3

@implementation FirstViewController
@synthesize secondVC, thirdVC;
@synthesize enterButton;
@synthesize aboutButton;
@synthesize tutorialViewController;
@synthesize tweetButton;
@synthesize activityIndicator;
@synthesize activityLabel;

#pragma mark Loading

-(void)viewWillAppear:(BOOL)animated {
    [TestFlight passCheckpoint:@"Opened Main Menu"];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if ([[PSCore core] pdRunning]==YES) {
        [self fadeInAfterLoading];
        NSLog(@"PSCore says Pd is running");        
    }else{
        NSLog(@"PSCore says Pd is not running");
        [activityIndicator startAnimating];
        activityIndicator.hidden = NO;
        
        [activityLabel setFont:[UIFont fontWithName:@"Helvetica Neue LT Com" size:14.0]];
        
        [UIView beginAnimations:@"activityLabelAnimation" context:nil];
        [UIView setAnimationDuration:1.5];
        [UIView setAnimationRepeatCount:50];
        [UIView setAnimationRepeatAutoreverses:YES];
        
        activityLabel.alpha = 0;
        
        [UIView commitAnimations];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:@"audioSessionStarted" object:nil];
    }
}

-(void)fadeInAfterLoading{
    NSLog(@"Fade in after loading has run");
    [activityIndicator stopAnimating];
    activityIndicator.hidden = YES;
    
    activityLabel.hidden = YES;
    
    // Show the tutorial?
    if ([[PSCore core] firstRun] == YES) {
        NSLog(@"This is the first run and therefore we're going to show the tutorial");
        [self performSelectorOnMainThread:@selector(showTutorial) withObject:nil waitUntilDone:NO];
    }  
    [self fadeInMenuBits];
}

-(void)fadeInMenuBits{
    NSLog(@"Main menu fadeInMenuBits has run");
    
    // Make sure the menu bits are at alpha=0 so we can fade them in    
    enterButton.alpha = 0;
    aboutButton.alpha = 0;
    
    // Fade the menu bits in
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:1.0];
    
    enterButton.alpha = 1;
    aboutButton.alpha = 1;
    logo.alpha = 1;
    
    [UIView commitAnimations];
}

#pragma mark Buttons

-(IBAction)pressedButton:(id)sender {
    UIButton *buttonPressed = (UIButton *)sender;
    
    // Fade menu bits away
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:kMenuBitsFadeTime];
    
    enterButton.alpha = 0;
    aboutButton.alpha = 0;
    logo.alpha = 0;
    
    [UIView commitAnimations];
    
    // Decide which view to switch to based on the tag of the button pressed
	switch (buttonPressed.tag) {
		case 2:
            [self performSelector:@selector(goToGallery) withObject:nil afterDelay:0.3];
			break;
		case 3:
            [self performSelector:@selector(goToAbout) withObject:nil afterDelay:0.3];
			break;
	}
}

// Go to the Gallery view
-(void)goToGallery{
    viewController=secondVC;
    [[self navigationController] pushViewController:secondVC animated:NO];
}

// Go to the About view
-(void)goToAbout{
    viewController=thirdVC;
    [[self navigationController] pushViewController:thirdVC animated:NO];
}

#pragma mark Tutorial

-(void)showTutorial{
    [self.navigationController.view addSubview:self.tutorialViewController.view];
    [self.tutorialViewController viewWillAppear:NO];
}

@end
