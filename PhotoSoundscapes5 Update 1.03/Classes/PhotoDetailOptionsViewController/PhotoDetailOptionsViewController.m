//
//  PhotoDetailOptionsViewController.m
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCore.h"
#import "PhotoDetailOptionsViewController.h"
#import "PhotoDetailViewController.h"
#import "PdBase.h"

@implementation PhotoDetailOptionsViewController

@synthesize optionsView;
@synthesize parent;

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

- (void)viewWillAppear:(BOOL)animated {
    [self slideIn];
}

- (void)slideIn{
    //set initial location at bottom of view
    CGRect frame = self.optionsView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.optionsView.frame = frame;
    [self.view addSubview:self.optionsView];
    
    //animate to new location, determined by height of the view in the NIB
    [UIView beginAnimations:@"presentWithSuperview" context:nil];
    frame.origin = CGPointMake(0.0, 
                               self.view.bounds.size.height - self.optionsView.bounds.size.height);
    
    self.optionsView.frame = frame;
    [UIView commitAnimations];
}

- (void) slideOut {
    [UIView beginAnimations:@"removeFromSuperviewWithAnimation" context:nil];
    
    // Set delegate and selector to remove from superview when animation completes
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    
    // Move this view to bottom of superview
    CGRect frame = self.optionsView.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    self.optionsView.frame = frame;
    
    [UIView commitAnimations];
    
    [[PSCore core] testMethod];
    [PdBase computeAudio:YES];
                                                            
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if ([animationID isEqualToString:@"removeFromSuperviewWithAnimation"]) {
        [self.view removeFromSuperview];
    }
}

- (IBAction)facebookShare {
    [PdBase computeAudio:NO];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

@end
