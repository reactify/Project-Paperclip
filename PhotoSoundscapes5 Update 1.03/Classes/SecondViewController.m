//
//  SecondViewController.m
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import "PSCore.h"
#import "SecondViewController.h"
#import "PhotoDetailViewController.h"
#import "PdBase.h"
#import "TutorialViewController.h"
#import "FirstViewControllerAppDelegate.h"

#define kNumberOfPhotos 19

static NSString *NameKey = @"nameKey";
static NSString *ImageKey = @"imageKey";
static NSString *DescriptionKey = @"descriptionKey";
static NSString *AccessQR = @"accessQR";
static NSString *AccessKey = @"accessKey";
static NSString *UnlockedPhotoKey = @"photoUnlocked";

@implementation SecondViewController

@synthesize scrollView, pageControl, photoDetailViewController;
@synthesize photoUnlocked;
@synthesize activityIndicator;
@synthesize firstViewController;

#pragma mark - Loading

- (void)viewDidLoad {
    
    [super viewDidLoad];
	
	pageControlBeingUsed = NO;
	
    [activityIndicator startAnimating];
    activityIndicator.hidden = NO;
    
    [self.view addSubview:activityIndicator];
    
    // TO-DO
    // Change this number of pages to a .count of number of images in the photoInfo.plist
    numberOfPagesToPopulate = kNumberOfPhotos;
	
    // Make the scroll view content the size of however many pages we have
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPagesToPopulate, self.scrollView.frame.size.height);
	
    // Reset the page control view
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = numberOfPagesToPopulate;
    
    [self performSelectorInBackground:@selector(populateGallery) withObject:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [TestFlight passCheckpoint:@"Opened Gallery View"];
    
    NSLog(@"Gallery viewWillAppear has run");
    
    self.scrollView.alpha = 0.0;
    self.pageControl.alpha = 0.0;
    backButton.alpha = 0.0;
    scanButton.alpha = 0.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelay:0.3];
    
    self.scrollView.alpha = 1.0;
    self.pageControl.alpha = 1.0;
    backButton.alpha = 1.0;
    scanButton.alpha = 1.0;
    mainBG.alpha = 1;
    
    [UIView commitAnimations];    
}

- (void)populateGallery{
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    int i = 0;
    // Populate the gallery
	for (int j = 0; j < numberOfPagesToPopulate; j++) {
        
        i = j;
        
        // If photoInfo.plist has 19 entries i.e. it's an old one, then we need to skip image 12 (Eye Of The Beholder)
        /*
         if ([[PSCore core]contentArray].count == 19) {
            if (j > 10) {
                i = j+1;
                NSLog(@"Old photoInfo.plist, so we're adding 1 to j - making it %i", i);
                specialOldPhotoInfoCase = YES;
            }else{
                i = j;
                NSLog(@"Old photoInfo.plist but we're less than 11 so i can be j (%i)", i);
                specialOldPhotoInfoCase = NO;
            };
        }else{
            NSLog(@"New photoInfo.plist so making i = j (%i)", j);
            i = j;
            specialOldPhotoInfoCase = NO;
        };
         */
		
        // For use later in the loop
        NSString *iAsString = [NSString stringWithFormat:@"%d", i];
        
        // Create frame for content in UIScrollView
        CGRect frame;
        if (specialOldPhotoInfoCase == YES) {
            frame.origin.x = self.scrollView.frame.size.width * (i-1);
//            NSLog(@"Special placement case (%f)", frame.origin.x);
        }else{
            frame.origin.x = self.scrollView.frame.size.width * i;
//            NSLog(@"Normal placement case (%f)", frame.origin.x);
        };
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
        
		UIView *subview = [[UIView alloc] initWithFrame:frame];
		
        // Declare the dictionaries of the image arrays
        numberItem = [[[PSCore core]contentArray] objectAtIndex:i];
        
        // Create the image to live in the button (get it from the dictionary declared above)
        UIImage *buttonImage = [UIImage imageNamed:[NSString stringWithFormat:@"g%@", [numberItem valueForKey:ImageKey]]];
        
        // Make the image button
        // Init the rect for each button
        CGRect buttonFrame;
        
        // Make the rect the right dimensions based on which is greater out of image width or height        
        if (buttonImage.size.width > buttonImage.size.height) {
            // define what the width of landscape photos should be
            buttonFrame.size.width = 275;
            // scale the height to be proportional to what we've scaled the width to
            buttonFrame.size.height = buttonImage.size.height/(buttonImage.size.width/buttonFrame.size.width);
        }else{
            // define height
            buttonFrame.size.height = 310;
            // opposite process to the above
            buttonFrame.size.width = buttonImage.size.width/(buttonImage.size.height/buttonFrame.size.height);
        }        
        
        // Center the image based on scroll view frame size
		buttonFrame.origin.x = (frame.size.width / 2) - (buttonFrame.size.width/2);
		buttonFrame.origin.y = (frame.size.height / 2) - (buttonFrame.size.height/2);
        
        // Create the button
		UIButton *subviewButton = [UIButton buttonWithType:UIButtonTypeCustom];
        subviewButton.frame = buttonFrame;
        subviewButton.backgroundColor = [UIColor clearColor];
        
        // Tag each button view with i + 200 so we can turn off their responsiveness to touches individually later
		subviewButton.tag = i+200;
        subviewButton.adjustsImageWhenHighlighted = NO;
        
        // Turn off user interaction by default - i.e. when the locks are on
//        subviewButton.userInteractionEnabled = NO;
        
        // Assign the button to relevant method to call
        [subviewButton addTarget:self action:@selector(imageTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        // Set background image for buttons to be the photo image
        [subviewButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        // Add the button to the subview
        [subview addSubview:subviewButton];
        
        // Make the black image overlay for locked images
        UIImageView *imageBlackBG = [[UIImageView alloc] initWithFrame:buttonFrame];
        imageBlackBG.backgroundColor = [UIColor blackColor];
        imageBlackBG.alpha = 0.5;
        imageBlackBG.userInteractionEnabled = NO;
        imageBlackBG.tag = i+400;
        [subview addSubview:imageBlackBG];
        
        // Add the lock image
        // Determined on which access type the image has
        NSNumber *accessTypeNumber = [numberItem valueForKey:AccessKey];
        int accessType = [accessTypeNumber intValue];
        
        // Default lock image
        NSString *lockImageToAdd = [NSString stringWithFormat:@"lock2.png"];
        
        switch (accessType) {
            case 0:
                lockImageToAdd = @"lock2.png";
                break;
            case 1:
                lockImageToAdd = @"lock2-physical.png";
                break;
            case 2:
                lockImageToAdd = @"lock2-online.png";
                break;
            default:
                break;
        }
        
        UIImage *lockImage = [UIImage imageNamed:lockImageToAdd];
        
        UIButton *lockButton = [UIButton buttonWithType:UIButtonTypeCustom];
        lockButton.frame = CGRectMake(
                                      ((frame.size.width / 2) - 112),
                                      ((frame.size.height / 2) + ((buttonFrame.size.height/2)-55)),
                                      223, 47);
       
        // Assign the method
        [lockButton addTarget:self action:@selector(lockTouched:) forControlEvents:UIControlEventTouchUpInside];
        [lockButton setBackgroundImage:lockImage forState:UIControlStateNormal];
        lockButton.adjustsImageWhenHighlighted = NO;
        
        // Tag each lock view with i + 100 so we can remove them individually later
        lockButton.tag = i+100;
        [subview addSubview:lockButton];
        
        
        // Read from the unlockedPhotosArray (loaded in PSCore) and HIDE the lock view if there IS an object in the array for this run in the for loop
        BOOL isPhotoUnlocked = [[[PSCore core]unlockedPhotosArray2] containsObject:iAsString];
        if(isPhotoUnlocked == YES) {
            lockButton.hidden = YES;
            subviewButton.userInteractionEnabled = YES;
            imageBlackBG.hidden = YES;
        }
        
        [imageBlackBG release];
                
        // Shadow image
        // Init frame
        CGRect shadowFrame;
        // make it slightly narrower than the image
        shadowFrame.size.width = buttonFrame.size.width;
        // scale the height
        shadowFrame.size.height = 16;
        // centre it about the button frame
        shadowFrame.origin.x = ((frame.size.width / 2) - (shadowFrame.size.width/2));
        // offset it from the bottom
        shadowFrame.origin.y = (frame.size.height - 38);
        // init the imageView
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:shadowFrame];

        // set the image
        shadowImageView.image = [UIImage imageNamed:@"shadow.png"];
        
        // Add it to the subview
        [subview addSubview:shadowImageView];
        
        [shadowImageView release];
        
        // Add the photo Title
        UILabel *photoTitle = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, 50)];
        photoTitle.text = [numberItem valueForKey:NameKey];
        photoTitle.backgroundColor = [UIColor clearColor];
        photoTitle.textColor = [UIColor whiteColor];
        photoTitle.textAlignment = UITextAlignmentCenter;
        [photoTitle setFont:[UIFont fontWithName:@"Helvetica Neue LT Com" size:16.0]];
        
        // Tag them so we can fade them in/out when the user is scrolling
        photoTitle.tag = 300+i;
        
        [subview addSubview:photoTitle];
        
        [photoTitle release];
        
		[self.scrollView addSubview:subview];
        
		[subview release];
    }
    
    [activityIndicator removeFromSuperview];
    [self fadeTheGalleryIn];

    [pool release];
    
}

- (void)fadeTheGalleryIn{
    
    self.scrollView.alpha = 0.0;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    
    self.scrollView.alpha = 1.0;
    
    [UIView commitAnimations];    
}

#pragma mark - Scrolling

- (IBAction)changePage {
    // update the scroll view to the appropriate page when using the Page Control dots
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeingUsed = YES;
    
    [self fadeTitlesOut];
    [self performSelector:@selector(fadeTitlesIn) withObject:nil afterDelay:0.1];    
}

- (void)scrollViewDidScroll:(UIScrollView *)sender {
    if (pageControlBeingUsed) {
        // do nothing - the scroll was initiated from the page control, not the user dragging
        return;
    }
    
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    self.pageControl.currentPage = page;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    
    // Fade image title away while scrolling
    [self fadeTitlesOut];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    
    // Fade image title back in after scrolling
    [self fadeTitlesIn];
}

- (void)fadeTitlesOut{
    // Fade out the photo title
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.1];
    
    // Current one, and both either side
    [self.scrollView viewWithTag:self.pageControl.currentPage+299].alpha = 0;
    [self.scrollView viewWithTag:self.pageControl.currentPage+300].alpha = 0;
    [self.scrollView viewWithTag:self.pageControl.currentPage+301].alpha = 0;
    
    [UIView commitAnimations];
}

- (void)fadeTitlesIn{
    // Bring back the photo title
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    [UIView setAnimationDelay:0.4];
    
    // Current one, and both either side
    [self.scrollView viewWithTag:self.pageControl.currentPage+299].alpha = 1;
    [self.scrollView viewWithTag:self.pageControl.currentPage+300].alpha = 1;
    [self.scrollView viewWithTag:self.pageControl.currentPage+301].alpha = 1;
    
    [UIView commitAnimations];
}

#pragma mark - Buttons

- (IBAction)imageTouched:(UIButton*)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    
    self.scrollView.alpha = 0.0;
    self.pageControl.alpha = 0.0;
    backButton.alpha = 0.0;
    scanButton.alpha = 0.0;
    mainBG.alpha = 0;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(goToPhotoDetail:) withObject:[NSNumber numberWithInt:sender.tag-200] afterDelay:0.6];
}

-(IBAction)pressedButton {
    // Back button
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView setAnimationDuration:0.6];
    
    self.scrollView.alpha = 0.0;
    self.pageControl.alpha = 0.0;
    backButton.alpha = 0.0;
    scanButton.alpha = 0.0;
    
    [UIView commitAnimations];
    
    [self performSelector:@selector(backToMainMenu) withObject:nil afterDelay:0.6];
}

- (void)backToMainMenu {
    // Go back to the main menu
	[[self navigationController] popViewControllerAnimated:NO];
}

- (void)lockTouched:(id)sender{
    [self scanButtonTapped];
}

#pragma mark - QR scanner

-(IBAction) scanButtonTapped {
    // ADD: present a barcode reader that scans from the camera feed
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader animated: YES];
    [reader release];    
}

- (void) imagePickerController: (UIImagePickerController*) reader didFinishPickingMediaWithInfo: (NSDictionary*) info {
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    NSString *qrCodeData = symbol.data;
    
    // If photoInfo.plist only has 18 entries then we need to correct the QR codes for everything after photo 11
    if ([[PSCore core]contentArray].count == 18) {
        // BUG FIX
        if ([qrCodeData intValue] < 12) {
            pickedQRCodeData = [qrCodeData intValue]-1;
            NSLog(@"Minusing 1 from qrCodeData");
        }else{
            pickedQRCodeData = [qrCodeData intValue]-2;
            NSLog(@"Minusing 2 from qrCodeData");
        }
    }else{
        // Otherwise (i.e. there are 19 entries), we can leave them as they were
        pickedQRCodeData = [qrCodeData intValue]-1;
        NSLog(@"Minusing 1 from qrCodeData.2");
    }
    
    NSLog(@"Picked QR code with data: %d", pickedQRCodeData);
    
    [reader dismissModalViewControllerAnimated: YES];
    
    [self checkQRCode:[NSNumber numberWithInt:pickedQRCodeData]];
}

#pragma mark - QR code scanned

- (void)checkQRCode:(NSNumber*)qrCodeData{
    
    int qrCodeDataInt = [qrCodeData intValue];
    
//    NSLog(@"Picked QR code data: %i", qrCodeData);
    
    // Check this QR code is at all in range...
    if (qrCodeDataInt >= 0 && qrCodeDataInt < 22) {        
        // Read the photoInfo.plist info for this QR code
        numberItem = [[[PSCore core]contentArray] objectAtIndex:qrCodeDataInt];
        
        photoNumber = [numberItem valueForKey:AccessQR];
        int photoNumberInt = [photoNumber intValue];
        int photoIndex = photoNumberInt-1;
        
        NSLog(@"Photo index = %i", photoIndex);
        
        NSNumber *accessTypeNumber = [numberItem valueForKey:AccessKey];
        
        int accessType = [accessTypeNumber intValue];
        
        // Check access type (online only (2), physical only (1) or both (0))
        switch (accessType) {
            case 0:
                // Unlock it
                [self goToPhotoDetail:[NSNumber numberWithInt:photoIndex]];
                [self scrollToPosition:photoIndex];
                [self unlockPhoto];
                break;
            case 1:
                // Unlock it
                [self goToPhotoDetail:[NSNumber numberWithInt:photoIndex]];
                [self scrollToPosition:photoIndex];
                [self unlockPhoto];
                break;
            case 2:
                // Unlock it
                [self goToPhotoDetail:[NSNumber numberWithInt:photoIndex]];
                [self scrollToPosition:photoIndex];
                [self unlockPhoto];
                break;
            default:
                break;
        }
    }else{
        // If QR code is out of range...
        NSLog(@"Invalid QR Code!");
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"Invalid QR code scanned"
                              message:@"Please visit a physical exhibition or DiscloseProjectPaperclip.com to unlock photographs."
                              delegate:nil
                              cancelButtonTitle:@"Okay"
                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

-(void)removeLock:(int)iteration {
    [TestFlight passCheckpoint:@"Unlocked a photo"];
    
    // Hide the lock
    UIView *viewToHide = [self.scrollView viewWithTag:iteration+100];
    viewToHide.hidden = YES;
    
    // Hide the dark image overlay
    UIView *bgToHide = [self.scrollView viewWithTag:iteration+400];
    bgToHide.hidden = YES;
    
    // And reenable touches for that image
    UIView *imageToEnableTouchesFor = [self.scrollView viewWithTag:iteration+200];
    imageToEnableTouchesFor.userInteractionEnabled = YES;
}

- (IBAction)scrollToPosition:(int)pageToScrollTo{    
    // Define the contents and bounds sizes
    CGSize csz = scrollView.contentSize;
    CGSize bsz = scrollView.bounds.size;
    
    // Make a point on the UIScrollView relating to the number picked by the QR Code (pickedQRCodeData) and scroll to that point
    [scrollView setContentOffset:CGPointMake((bsz.width*pageToScrollTo), csz.height - bsz.height) animated:YES];
}

-(void)unlockPhoto{
    // Send a message to the core to add this unlocked photo to the unlockedPhotosArray
    [[PSCore core] unlockPhoto:pickedQRCodeData];
    
    // Hide the lock from the view
    [self removeLock:pickedQRCodeData];
}

- (void)goToPhotoDetail:(NSNumber *)photoNumber2 {
    NSInteger photoNumber = [photoNumber2 intValue];
    
    [photoDetailViewController setImageTouched:photoNumber];
    
    [PdBase sendBangToReceiver:@"stopInterfaceMusic"];
    
    [[self navigationController] pushViewController:photoDetailViewController animated:NO];
}

#pragma mark - Unloading

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;    
    NSLog(@"Gallery viewDidUnload has run");
}

- (void)dealloc {
    [scrollView release];
    [super dealloc];
    
    NSLog(@"Gallery dealloc has run");
}

@end
