//
//  TutorialViewController.m
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 03/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TutorialViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FirstViewController.h"
#import "PSCore.h"

@implementation TutorialViewController

@synthesize tutorialView;
@synthesize parent;
@synthesize closeButton;
@synthesize firstViewController;
@synthesize scrollView, pageControl;

- (void)viewWillAppear:(BOOL)animated {
    [self fadeIn];
}

-(void)fadeIn{
    
    CGRect frame = self.tutorialView.frame;
    frame.origin = CGPointMake(0, 0);
    self.tutorialView.frame = frame;
    
    [self.view addSubview:self.tutorialView];
    
    tutorialView.alpha = 0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5];
    tutorialView.alpha = 1;
    [UIView commitAnimations];
    
    NSLog(@"Tutorial view has faded in");
    
}

-(IBAction)closeTutorial{
    
    
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];    
    [UIView setAnimationDuration:0.5];
    tutorialView.alpha = 0;
    [UIView commitAnimations];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {        
        [self.view removeFromSuperview];
        NSLog(@"Tutorial has been removed from superview");
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
	if (!pageControlBeingUsed) {
		// Switch the indicator when more than 50% of the previous/next page is visible
		CGFloat pageWidth = self.scrollView.frame.size.width;
		int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
		self.pageControl.currentPage = page;
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
	pageControlBeingUsed = NO;
    if (self.pageControl.currentPage == 2) {
        [self showCloseButton];
        [self changeFirstRunToNo];
    }
}


-(void)showCloseButton {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.4];
    closeButton.alpha = 1;
    [UIView commitAnimations];
}

-(void)changeFirstRunToNo{
    [[PSCore core] setFirstRunToNo];
    NSLog(@"Tutorial has set firstRun to NO");
}

- (IBAction)changePage {
	// Update the scroll view to the appropriate page
	CGRect frame;
	frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
	frame.origin.y = 0;
	frame.size = self.scrollView.frame.size;
	[self.scrollView scrollRectToVisible:frame animated:YES];
	
	pageControlBeingUsed = YES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    pageControlBeingUsed = NO;
    
    closeButton.alpha = 0;
	
	self.scrollView.contentSize = CGSizeMake(960, 444);
    
    [tut1Text setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]];
    [tut1Title setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:18.0]]; 
    [tut1Title4 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:14.0]]; 
    [tut1Title2 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:16.0]]; 
    [tut1Title3 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:15.0]]; 
    [tut2Text setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:14.0]]; 
    [tut2Title setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:64.0]];
    [tut3Text1 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:22.0]];
    [tut3Text12 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:22.0]];
    [tut3Text2 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:22.0]];
    [tut3Text22 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:22.0]];
    [tut3Text3 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:22.0]];
    [tut3Text32 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:22.0]];
    [tut3Text4 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-MdCn" size:22.0]];
    [tut3Text42 setFont:[UIFont fontWithName:@"HelveticaNeueLTCom-BdCn" size:22.0]];
    
}

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

- (void)dealloc {
    NSLog(@"Tutorial view dealloc has run");
    [scrollView release];
	[pageControl release];
}
@end
