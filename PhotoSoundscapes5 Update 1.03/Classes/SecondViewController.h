//
//  SecondViewController.h
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudio.h"

#define myAppDelegate (FirstViewControllerAppDelegate *) [[UIApplication sharedApplication] delegate]

@class PhotoDetailViewController;
@class FirstViewController;

@interface SecondViewController : UIViewController <ZBarReaderDelegate> {
    PdAudio *pdAudio;
    UIScrollView* scrollView;
    UIPageControl* pageControl;
    BOOL pageControlBeingUsed;
    int numberOfPages;
    int numberOfPagesToPopulate;
	IBOutlet PhotoDetailViewController *photoDetailViewController;
    FirstViewController *firstViewController;
    int pickedQRCodeData;
    BOOL photoUnlocked;
    int imageTouched;
    IBOutlet UIButton *scanButton;
    IBOutlet UIButton *backButton;
    IBOutlet UIImageView *mainBG;
    IBOutlet UIActivityIndicatorView *activityIndicator;
    NSDictionary *numberItem;
    BOOL specialOldPhotoInfoCase;
}

@property (nonatomic, assign) BOOL photoUnlocked;
@property (nonatomic, retain) IBOutlet UIScrollView* scrollView;
@property (nonatomic, retain) IBOutlet UIPageControl* pageControl;
@property (nonatomic, retain) PhotoDetailViewController *photoDetailViewController;
@property (nonatomic, retain) FirstViewController *firstViewController;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (IBAction)pressedButton;
- (IBAction)changePage;
- (IBAction)imageTouched:(UIButton*)sender;
- (IBAction)scanButtonTapped;
- (IBAction)scrollToPosition:(int)pageToScrollTo;
- (void)goToPhotoDetail:(NSNumber*)photoNumber;
- (void)removeLock:(int)iteration;
- (void)populateGallery;
- (void)fadeTheGalleryIn;
- (void)checkQRCode:(NSNumber*)photoNumber;
- (void)fadeTitlesOut;
- (void)fadeTitlesIn;
- (void)unlockPhoto;

@end