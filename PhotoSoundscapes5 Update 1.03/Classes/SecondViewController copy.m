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

static NSString *NameKey = @"nameKey";
static NSString *ImageKey = @"imageKey";
static NSString *DescriptionKey = @"descriptionKey";
static NSString *UnlockedPhotoKey = @"photoUnlocked";

@implementation SecondViewController

@synthesize scrollView, pageControl, photoDetailViewController;
@synthesize photoUnlocked;

- (void)viewDidLoad {
        
    [super viewDidLoad];
	
	pageControlBeingUsed = NO;
	
    numberOfPages = 6;
    
	for (int i = 0; i < numberOfPages; i++) {
		
        NSString *iAsString = [[NSString alloc] initWithFormat:@"%d", i];
        
        // Create frame for content in UIScrollView
        CGRect frame;
		frame.origin.x = self.scrollView.frame.size.width * i;
		frame.origin.y = 0;
		frame.size = self.scrollView.frame.size;
        
		UIView *subview = [[UIView alloc] initWithFrame:frame];
		
        // Declare the dictionaries of the arrays we use
        // Image array
        NSDictionary *numberItem = [[[PSCore core]contentArray] objectAtIndex:i];
        
        
        // Create the image to live in the button
        UIImage *buttonImage = [UIImage imageNamed:[numberItem valueForKey:ImageKey]];
        
        /*
        // Create the image view for the photo
        UIImageView *photoView = [[UIImageView alloc] initWithImage:buttonImage];
        // Set the photo's content mode
        photoView.contentMode = UIViewContentModeCenter;
        //Add it to the subview
        [subview addSubview:photoView];
        */
        
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
        if (i > 0) {
//            subviewButton.userInteractionEnabled = NO;
        }
        
        // Separate the methods to call
        // Set imageTouched as the default method to call for when an image was touched
        SEL methodToCall = @selector(imageTouched:);
        // However, if the camera image was touched i.e. i == 0, call the scanButtonTapped method, instead
        if (i == 0) methodToCall = @selector(scanButtonTapped);
        
        // Assign the button to the relevant method to call, defined above
        [subviewButton addTarget:self action:methodToCall forControlEvents:UIControlEventTouchUpInside];
        
        
        // Set background image for buttons to be the image
        [subviewButton setBackgroundImage:buttonImage forState:UIControlStateNormal];
        
        // Add the button to the subview
        [subview addSubview:subviewButton];
                
        // Add the lock image
        UIImageView *lockView = [[UIImageView alloc] initWithFrame:CGRectMake(((frame.size.width / 2) - 150), ((frame.size.height / 2) - 190), 300, 300)];
        lockView.image = [UIImage imageNamed:@"lock.png"];
        
        // Tag each lock view with i + 100 so we can remove them individually later
        lockView.tag = i+100;
        if (i > 0) {
//            [subview addSubview:lockView];
        }
        
        // Read from the unlockedPhotosArray and insert add a lock view if there isn't an object in the photosUnlockedArray for this run in the for loop
        BOOL isPhotoUnlocked = [[[PSCore core]unlockedPhotosArray2] containsObject:iAsString];
        if(isPhotoUnlocked == YES) {
            lockView.hidden = YES;
            subviewButton.userInteractionEnabled = YES;
        }
		
        // Shadow image
        // Init frame
        CGRect shadowFrame;
        // make it slightly narrower than the image
        shadowFrame.size.width = buttonFrame.size.width * 0.8;
        // scale the height to the width (assuming the image us of a ratio 24.1:1)
        shadowFrame.size.height = shadowFrame.size.width / 24.1;
        // centre it about the button frame
        shadowFrame.origin.x = ((buttonFrame.size.width / 2) - (shadowFrame.size.width/2));
        // offset it from the bottom
        shadowFrame.origin.y = (frame.size.height - 31);
        UIImageView *shadowImageView = [[UIImageView alloc] initWithFrame:shadowFrame];
        shadowImageView.image = [UIImage imageNamed:@"shadow.png"];
        
        // Add it to the subview
        [subview addSubview:shadowImageView];
        
        // Add the photo Title
        UILabel *photoTitle = [[UILabel alloc] initWithFrame:CGRectMake(61, -11, 194, 50)];
        photoTitle.text = [numberItem valueForKey:NameKey];
        photoTitle.backgroundColor = [UIColor clearColor];
        photoTitle.textColor = [UIColor whiteColor];
        photoTitle.textAlignment = UITextAlignmentLeft;
        [photoTitle setFont:[UIFont fontWithName:@"Helvetica Neue LT Com" size:14.0]];
        
        // Tag them so we can fade them in/out when the user is scrolling
        photoTitle.tag = 300+i;
        
        [subview addSubview:photoTitle];
        
        // Add the photo Description
        UILabel *photoDescription = [[UILabel alloc] initWithFrame:CGRectMake(61, 8, 194, 50)];
        photoDescription.text = [numberItem valueForKey:DescriptionKey];
        photoDescription.backgroundColor = [UIColor clearColor];
        photoDescription.textColor = [UIColor grayColor];
        photoDescription.textAlignment = UITextAlignmentLeft;
        [photoDescription setFont:[UIFont fontWithName:@"Helvetica Neue LT Com" size:14.0]];
        
        
        // Tag them so we can fade them in/out when the user is scrolling
        photoDescription.tag = 300+numberOfPages+i;
        
        [subview addSubview:photoDescription];
        
		[self.scrollView addSubview:subview];
        
		[subview release];
	}
	
    // Make the scroll view content the size of however many pages we have
	self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width * numberOfPages, self.scrollView.frame.size.height);
	
    // Reset the page control view
	self.pageControl.currentPage = 0;
	self.pageControl.numberOfPages = numberOfPages;
}


- (void)viewWillAppear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
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
    
    [UIView commitAnimations];
    
}

-(void)removeLock:(int)iteration{ 
    UIView *viewToHide = [self.scrollView viewWithTag:iteration+100];
    viewToHide.hidden = YES;
    UIView *imageToEnableTouchesFor = [self.scrollView viewWithTag:iteration+200];
    imageToEnableTouchesFor.userInteractionEnabled = YES;
}

#pragma mark -

- (IBAction) scanButtonTapped
{
    // ADD: present a barcode reader that scans from the camera feed
    
    ZBarReaderViewController *reader = [ZBarReaderViewController new];
    reader.readerDelegate = self;
    reader.supportedOrientationsMask = ZBarOrientationMaskAll;
    
    ZBarImageScanner *scanner = reader.scanner;
    // TODO: (optional) additional reader configuration here
    
    // EXAMPLE: disable rarely used I2/5 to improve performance
    [scanner setSymbology: ZBAR_I25
                   config: ZBAR_CFG_ENABLE
                       to: 0];
    
    // present and release the controller
    [self presentModalViewController: reader animated: YES];
    [reader release];
    
}


- (void) imagePickerController: (UIImagePickerController*) reader
 didFinishPickingMediaWithInfo: (NSDictionary*) info
{
    // ADD: get the decode results
    id<NSFastEnumeration> results =
    [info objectForKey: ZBarReaderControllerResults];
    ZBarSymbol *symbol = nil;
    for(symbol in results)
        // EXAMPLE: just grab the first barcode
        break;
    
    
    NSString *qrCodeData = symbol.data;
    pickedQRCodeData = [qrCodeData intValue];
    
    NSLog(@"Picked QR code with data: %d", pickedQRCodeData);
    
    /*
    // EXAMPLE: do something useful with the barcode data
    resultText.text = symbol.data;
    
    // EXAMPLE: do something useful with the barcode image
    resultImage.image =
    [info objectForKey: UIImagePickerControllerOriginalImage];
    */
    
    // ADD: dismiss the controller (NB dismiss from the *reader*!)
    
    
    [reader dismissModalViewControllerAnimated: YES];
    
    [self scrollToPosition];
    
    [self goToPhotoDetail:pickedQRCodeData:NO];
}

- (void)goToPhotoDetail:(int)photoNumber:(BOOL)animatedTransition {
    
    [photoDetailViewController populateImageView:photoNumber];
    [photoDetailViewController launchPdSubpatch:photoNumber];
    
    [[self navigationController] pushViewController:photoDetailViewController animated:YES];
}
- (IBAction)scrollToPosition{    
    
    // Define the contents and bounds sizes
    CGSize csz = scrollView.contentSize;
    CGSize bsz = scrollView.bounds.size;
    // Make a point on the UIScrollView relating to the number picked by the QR Code (pickedQRCodeData) and scroll to that point
    [scrollView setContentOffset:CGPointMake((bsz.width*pickedQRCodeData), csz.height - bsz.height) animated:YES];
    [[PSCore core] unlockPhoto:pickedQRCodeData];
    [self removeLock:pickedQRCodeData];
}

-(IBAction)pressedButton {
    
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

- (IBAction)imageTouched:(UIButton*)sender; {
    
//    NSInteger num = [sender tag];
    
    // UIButton *buttonOfImageTouched = (UIButton *)sender;
    // int num = [buttonOfImageTouched.tag intValue];
    
//    NSLog(@"Number of image touched is %i", sender.tag);
    [self goToPhotoDetail:sender.tag-200:YES];    
}



- (IBAction)changePage {
    // update the scroll view to the appropriate page
    CGRect frame;
    frame.origin.x = self.scrollView.frame.size.width * self.pageControl.currentPage;
    frame.origin.y = 0;
    frame.size = self.scrollView.frame.size;
    [self.scrollView scrollRectToVisible:frame animated:YES];
    
    pageControlBeingUsed = YES;
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
	[super touchesBegan:touches withEvent:event];
    
	UITouch *touch = [touches anyObject];
    
    NSLog(@"Touch tap count = %i", touch.tapCount);
	
        if (touch.tapCount == 1) {
            // Hmmmmmmm... Need to figure out how to detect the touches being absorbed by the UIScrollView...
        }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    for (int i = 0; i < numberOfPages*2; i++) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.1];
        
        UIView *textToHide = [self.scrollView viewWithTag:300+i];
        textToHide.alpha = 0;
        
        [UIView commitAnimations];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    pageControlBeingUsed = NO;
    
    for (int i = 0; i < numberOfPages*2; i++) {
        
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.6];
        [UIView setAnimationDelay:0.4];
        
        UIView *textToHide = [self.scrollView viewWithTag:300+i];
        textToHide.alpha = 1;
        
        [UIView commitAnimations];
    }
    
}


#pragma mark -

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.scrollView = nil;
}

- (void)dealloc {
    [scrollView release];
    [super dealloc];
}

@end
