//
//  PhotoDetailOptionsViewController.h
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 30/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//@class PhotoDetailViewController;

@interface PhotoDetailOptionsViewController : UIViewController {
    IBOutlet UIView *optionsView;
    IBOutlet UIButton *closeOptionsButton;
//    IBOutlet PhotoDetailViewController *photoDetailViewController;
}

@property (nonatomic, retain) IBOutlet UIView *optionsView;
@property (nonatomic, retain) UIViewController *parent;

- (void)slideIn;
- (IBAction)slideOut;
- (IBAction)facebookShare;

@end
