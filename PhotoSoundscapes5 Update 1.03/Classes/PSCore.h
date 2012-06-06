//
//  PSCore.h
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBConnect.h"
#import "ThirdViewController.h"
#import "PhotoDetailViewController.h"

#define kAppId @"319580604742956"
#define kFilename @"unlockedPhotosArray2.plist"
#define kAppStoreURL @"http://itunes.apple.com/us/app/project-paperclip/id492075000?ls=1&mt=8"
#define kOnlineGalleryURL @"http://www.discloseprojectpaperclip.com"
#define kTweetPrepopulatedContentFromAbout @"Check out #ProjectPaperclip from @nunoserrao - www.discloseprojectpaperclip.com"
#define kTweetPrepopulatedContentFromPhotoDetail @"Check out these photos from @nunoserrao - www.discloseprojectpaperclip.com, via #ProjectPaperclip"

#define kOAuthConsumerKey @"tM0bI89Cg4EnH4sT9sHHmg"
#define kOAuthConsumerSecret @"bowRvoDPQBJ46OtqLTDH5c0H6F5ifvcDgXdaNdPuGUo"

@class Facebook;
@class Reachability;

@interface PSCore : NSObject <FBSessionDelegate, FBDialogDelegate> {
    NSArray* contentArray;
    NSMutableArray* unlockedPhotosArray2;
    
    NSArray* paths;
    NSString* documentsDirectory;
    
    NSString *photoIDString;
    NSDictionary *contentDictionary;
    
    BOOL firstRun;
    
    ThirdViewController *thirdViewController;
    
    Facebook *facebook;
	BOOL isFacebookLoggedIn;
    NSString *photoToShare;
    NSString *nameOfPhotoToShare;
    NSString *descriptionOfFacebookPost;
    
    PhotoDetailViewController *photoDetailViewController;
    BOOL inGeofence1;
    
    Reachability* internetReachable;
    Reachability* hostReachable;
    
    BOOL internetActive;
    BOOL hostActive;
    BOOL pdRunning;
}

@property (nonatomic, retain) NSArray *contentArray;
@property (nonatomic, retain) NSMutableArray *unlockedPhotosArray2;
@property (nonatomic, retain) NSArray* paths;
@property (nonatomic, retain) NSString* documentsDirectory;
@property (nonatomic, retain) NSDictionary *contentDictionary;
@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) ThirdViewController *thirdViewController;
@property (nonatomic, retain) PhotoDetailViewController *photoDetailViewController;
@property BOOL isFacebookLoggedIn;
@property BOOL firstRun;
@property BOOL inGeofence1;
@property BOOL internetActive;
@property BOOL hostActive;
@property BOOL pdRunning;

+ (PSCore *)core;

- (void)unlockPhoto:(int)photoID;
- (void)testMethod;
- (NSString *)dataFilePath;
- (void)initFacebook;
- (void)setDetailsToShare:(NSString *)imageURL:(NSString *)imageName:(NSString *)postDescription;
- (void)shareFBPost:(NSString *)imageURL:(NSString *)imageName:(NSString *)postDescription;
- (void)dialogDidComplete:(FBDialog *)dialog;
- (void)dialogDidNotComplete:(FBDialog *)dialog;
- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error;

-(void)setInGeofence1ToYes;

-(void)facebookLogout;
-(void)setFirstRunToNo;

-(void)checkNetworkStatus:(NSNotification *)notice;

@end