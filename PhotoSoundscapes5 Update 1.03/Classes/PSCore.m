//
//  PSCore.m
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 21/12/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "PSCore.h"
#import "Twitter/Twitter.h"
#import "Facebook.h"
#import "ThirdViewController.h"
#import "Reachability.h"

static PSCore *sharedCore;

static NSString *NameKey = @"nameKey";
static NSString *ImageKey = @"imageKey";
static NSString *DescriptionKey = @"descriptionKey";
static NSString *UnlockedPhotoKey = @"photoUnlocked";

@implementation PSCore
@synthesize contentArray;
@synthesize unlockedPhotosArray2;
@synthesize contentDictionary;
@synthesize paths;
@synthesize documentsDirectory;

@synthesize facebook;

@synthesize thirdViewController;
@synthesize photoDetailViewController;

@synthesize isFacebookLoggedIn;
@synthesize firstRun;
@synthesize inGeofence1;
@synthesize internetActive;
@synthesize hostActive;
@synthesize pdRunning;

+(void)initialize {
	static BOOL initialised = NO;
	if (!initialised)
	{
		initialised = YES;
		sharedCore = [[PSCore alloc] init];
	}
}

+(PSCore *)core {
	@synchronized(self) {
		if (sharedCore == NULL) 
            sharedCore = [[self alloc] init];
	}
	return sharedCore;
}

- (NSString *)dataFilePath{
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:kFilename];
}

-(id)init {
    
    self = [super init];
    
    NSLog(@"PSCore init CODE HAS RUN!");
    
    UIApplication *app = [UIApplication sharedApplication];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillTerminate:)
                                                 name:UIApplicationWillTerminateNotification 
                                               object:app];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification 
                                               object:app];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"photoInfo" ofType:@"plist"];
    self.contentArray = [NSArray arrayWithContentsOfFile:path];
    NSLog(@"Content array count: %i", self.contentArray.count);
    
    contentDictionary = [contentArray objectAtIndex:1];

    NSString *filePath = [self dataFilePath];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        unlockedPhotosArray2 = [[NSMutableArray alloc] initWithContentsOfFile:filePath];
        NSLog(@"unlockedPhotosArray has loaded with contents of filePath");
        firstRun = NO;
    }else{
        unlockedPhotosArray2 = [[NSMutableArray alloc] init];
        NSLog(@"unlockedPhotosArray has been initialized for the first time");
        firstRun = YES;
    }
    
    NSLog(@"Contents of unlockedPhotosArray2 %@", unlockedPhotosArray2);
    
    facebook = [[Facebook alloc] initWithAppId:@"319580604742956" andDelegate:self];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"] 
        && [defaults objectForKey:@"FBExpirationDateKey"]) {
        facebook.accessToken = [defaults objectForKey:@"FBAccessTokenKey"];
        facebook.expirationDate = [defaults objectForKey:@"FBExpirationDateKey"];
    }
    
	NSLog(@"PSCore - FBAccessTokenKey: %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBAccessTokenKey"]);
	NSLog(@"PSCore - FBExpirationDateKey:%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBExpirationDateKey"]);
    
    
    // check for internet connection
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkNetworkStatus:) name:kReachabilityChangedNotification object:nil];
    
    internetReachable = [[Reachability reachabilityForInternetConnection] retain];
    [internetReachable startNotifier];
    
    // check if a pathway to a random host exists
    hostReachable = [[Reachability reachabilityWithHostName: @"www.apple.com"] retain];
    [hostReachable startNotifier];
    
    // now patiently wait for the notification
    
    pdRunning = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setPdRunningToYes) name:@"audioSessionStarted" object:nil];
    
    NSLog(@"CORE: documentsDirectory retain count: %i", [documentsDirectory retainCount]);
    
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    documentsDirectory = [[paths objectAtIndex:0] retain];
    
    NSLog(@"CORE: documentsDirectory retain count: %i", [documentsDirectory retainCount]);
    
    
    return self;
}

- (void)setPdRunningToYes{
    pdRunning = YES;
}

- (void) checkNetworkStatus:(NSNotification *)notice {
    // called after network status changes    
    NetworkStatus internetStatus = [internetReachable currentReachabilityStatus];
    switch (internetStatus)
    {
        case NotReachable: {
            NSLog(@"The internet is down.");
            self.internetActive = NO;
            break;
        }
        case ReachableViaWiFi: {
            NSLog(@"The internet is working via WIFI.");
            self.internetActive = YES;
            break;
        }
        case ReachableViaWWAN: {
            NSLog(@"The internet is working via WWAN.");
            self.internetActive = YES;
            break;
        }
    }
    
    NetworkStatus hostStatus = [hostReachable currentReachabilityStatus];
    switch (hostStatus) {
        case NotReachable: {
            NSLog(@"A gateway to the host server is down.");
            self.hostActive = NO;            
            break;            
        }
        case ReachableViaWiFi: {
            NSLog(@"A gateway to the host server is working via WIFI.");
            self.hostActive = YES;            
            break;            
        }
        case ReachableViaWWAN: {
            NSLog(@"A gateway to the host server is working via WWAN.");
            self.hostActive = YES;
            break;            
        }
    }
}

-(void)setFirstRunToNo{
    firstRun = NO;
}

- (void)testMethod{
    NSLog(@"Core test method has run");
}

-(void)setInGeofence1ToYes{
    inGeofence1 = YES;
}

-(void)unlockPhoto:(int)photoID {
    
    photoIDString = [NSString stringWithFormat:@"%i", photoID];
    
    [unlockedPhotosArray2 addObject:photoIDString];
    
    NSLog(@"Contents of unlockedPhotosArray2 %@", unlockedPhotosArray2);
}

#pragma mark -
#pragma mark Social
#pragma mark Facebook


- (void)initFacebook {
    
    [facebook authorize:nil];
    
//    [self fbDidLogin];
    
    NSLog(@"Facebook session now valid? = %i", [facebook isSessionValid]);
}


- (void)fbDidLogin {
    NSLog(@"fbDidLogin has run!!");
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[facebook accessToken] forKey:@"FBAccessTokenKey"];
    [defaults setObject:[facebook expirationDate] forKey:@"FBExpirationDateKey"];
    [defaults synchronize];
    
	NSLog(@"FBAccessTokenKey: %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBAccessTokenKey"]);
	NSLog(@"FBExpirationDateKey:%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBExpirationDateKey"]);
    
    NSLog(@"Setting isFacebookLoggedIn to YES");
    isFacebookLoggedIn = YES;
    
    [self shareFBPost:photoToShare:nameOfPhotoToShare:descriptionOfFacebookPost];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogin" object:self];
}


-(void)facebookLogout {
    [facebook logout];
}

- (void) fbDidLogout {
    // Remove saved authorization information if it exists
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults objectForKey:@"FBAccessTokenKey"]) {
        [defaults removeObjectForKey:@"FBAccessTokenKey"];
        [defaults removeObjectForKey:@"FBExpirationDateKey"];
        [defaults synchronize];
    }
    
	NSLog(@"FBAccessTokenKey: %@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBAccessTokenKey"]);
	NSLog(@"FBExpirationDateKey:%@",[[NSUserDefaults standardUserDefaults]valueForKey:@"FBExpirationDateKey"]);    
    NSLog(@"Logged out of Facebook");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDidLogout" object:self];
}

- (void)setDetailsToShare:(NSString *)imageURL :(NSString *)imageName:(NSString *)postDescription {
    NSLog(@"shareFBPost being called");
    
    photoToShare = [[NSString alloc] initWithFormat:@"http://www.reactifymusic.com/ppc/%@", imageURL];
    nameOfPhotoToShare = [[NSString alloc] initWithString:imageName];
    descriptionOfFacebookPost = [[NSString alloc] initWithString:postDescription];
    
    if (![facebook isSessionValid]) {
        NSLog(@"No valid fb session");
        [self initFacebook];
    }else{
        [self shareFBPost:photoToShare :nameOfPhotoToShare :descriptionOfFacebookPost];
    }
    
}

- (void)shareFBPost:(NSString *)imageURL:(NSString *)imageName:(NSString *)postDescription{
    NSLog(@"Actually sharing the post, now");
    
    NSLog(@"Sharing the picture at the following URL: %@", imageURL);
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   kAppId,                  @"app_id",
                                   kOnlineGalleryURL,       @"link",
                                   imageURL,                @"picture",
                                   @"Project Paperclip",    @"name",
                                   imageName,               @"caption",
                                   postDescription,         @"description",
                                   nil];
    
    [facebook dialog:@"feed"andParams:params andDelegate:self];
    
    [photoToShare release];
    [nameOfPhotoToShare release];
    [descriptionOfFacebookPost release];
}

- (void)dialogDidComplete:(FBDialog *)dialog{
    NSLog(@"FB dialog did complete: %@", dialog);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDialogDidComplete" object:self];
}

- (void) dialogDidNotComplete:(FBDialog *)dialog{
    NSLog(@"FB dialog did not complete: %@", dialog);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDialogDidNotComplete" object:self];
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error{
    if (error.code == NSURLErrorCancelled) {
        NSLog(@"Received NSURLErrorCancelled, but nevermind...");
    }else{
        NSLog(@"FB dialog did fail with error: %@", error);
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"facebookDialogDidFail" object:self];
}


#pragma mark Twitter



#pragma mark -

- (void)applicationWillResignActive:(NSNotification *)notification {
    NSLog(@"appWillResignActive code has run");
    [unlockedPhotosArray2 writeToFile:[self dataFilePath] atomically:YES];
}



@end
