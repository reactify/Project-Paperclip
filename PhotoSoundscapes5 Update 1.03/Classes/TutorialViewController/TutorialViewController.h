//
//  TutorialViewController.h
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 03/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FirstViewController;

@interface TutorialViewController : UIViewController <UIScrollViewDelegate> {
    FirstViewController *firstViewController;
    IBOutlet UIView *tutorialView;
    IBOutlet UIButton *closeButton;
	UIScrollView* scrollView;
	UIPageControl* pageControl;
	BOOL pageControlBeingUsed;
    
    IBOutlet UILabel *tut1Title;
    IBOutlet UILabel *tut1Title4;
    IBOutlet UITextView *tut1Text;
    IBOutlet UILabel *tut1Title2;
    IBOutlet UILabel *tut1Title3;
    IBOutlet UILabel *tut2Title;
    IBOutlet UITextView *tut2Text;
    IBOutlet UITextView *tut3Text1;
    IBOutlet UITextView *tut3Text2;
    IBOutlet UITextView *tut3Text3;
    IBOutlet UITextView *tut3Text4;
    IBOutlet UITextView *tut3Text12;
    IBOutlet UITextView *tut3Text22;
    IBOutlet UITextView *tut3Text32;
    IBOutlet UITextView *tut3Text42;
    
}

@property (nonatomic, retain) IBOutlet UIView *tutorialView;
@property (nonatomic, retain) UIViewController *parent;
@property (nonatomic, retain) IBOutlet UIButton *closeButton;

@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;

@property (nonatomic, retain) FirstViewController *firstViewController;

-(void)fadeIn;
-(IBAction)closeTutorial;
- (IBAction)changePage;
-(void)showCloseButton;
-(void)changeFirstRunToNo;

@end
