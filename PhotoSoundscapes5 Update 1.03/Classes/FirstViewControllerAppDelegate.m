//
//  FirstViewControllerAppDelegate.m
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import "FirstViewControllerAppDelegate.h"
#import "FirstViewController.h"
#import "PdBase.h"
#include <sys/xattr.h>

@interface FirstViewControllerAppDelegate()

- (void) openAndRunTestPatch;
- (void) copyDemoPatchesToUserDomain;


@end

@implementation FirstViewControllerAppDelegate

@synthesize window;
@synthesize navigationController;
@synthesize core;

@synthesize locationManager;
@synthesize startingPoint;

NSString *patchFileTypeExtension = @"pd";
NSString *wavFileTypeExtension = @"wav"; 
NSString *cFileTypeExtension = @"c";


#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
    // Test Flight stuff
    [TestFlight takeOff:@"5a4c681713efc0afc8c1195ec1f045b3_NTA0ODAyMDExLTEyLTMwIDA4OjQxOjExLjM0Mzk2Mw"];
    [TestFlight passCheckpoint:@"Opened app"];
    
    // Add the view controller's view to the window and display.
    [window addSubview:navigationController.view];
    [window makeKeyAndVisible];
    
    // Disable sleep timer
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    core = [PSCore core];
    
    firstViewController = [[FirstViewController alloc] init];
    
    // Initialize the location manager
    locationManager=[[CLLocationManager alloc] init];
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.delegate=self;
    
    //Start the location updates.
    [locationManager startUpdatingLocation];
    
    // Init Pure Data
    [self performSelectorInBackground:@selector(initPd) withObject:nil];
    
    return YES;
}


// Pre 4.2 support
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return 
    [[[PSCore core] facebook] handleOpenURL: url];
}

// For 4.2+ support
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSLog(@"Application openURL has run");
    return 
    [[[PSCore core] facebook] handleOpenURL: url];
}

#pragma mark - Location services

- (void) startUpdatingLocation{
    [locationManager startUpdatingLocation];
    NSLog(@"Location updates started");
}

- (void) stopUpdatingLocation{
    [locationManager stopUpdatingLocation];
    NSLog(@"Location updates stopped");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    if (startingPoint == nil)
        self.startingPoint = newLocation;  
//    [PdBase sendFloat:newLocation.coordinate.latitude toReceiver:@"#latitude"];
//    [PdBase sendFloat:newLocation.coordinate.longitude toReceiver:@"#longitude"];
    
    float newLatitude = newLocation.coordinate.latitude;
    float newLongitude = newLocation.coordinate.longitude;
    
//    [firstViewController updateLocationLabels:newLatitude];
    
    if (newLocation.coordinate.latitude != oldLocation.coordinate.latitude) {
//        NSLog(@"New latitude: %f", newLatitude);
//        NSLog(@"New longitude: %f", newLongitude);
        
        if (newLatitude < 33.5 && newLatitude > 32 && newLongitude < -18 && newLongitude > -16.2) {
//        if (newLatitude > 51 && newLatitude < 52 && newLongitude > -1 && newLongitude < 1) {
            NSLog(@"We're in Madeira!");
            [[PSCore core] setInGeofence1ToYes];
        }else{
            NSLog(@"We're not in Madeira!");
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
//    NSString *errorType = (error.code == kCLErrorDenied) ? @"Access Denied" : @"Unknown Error";
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting Location" message:errorType delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
//    [alert show];
//    [alert release];
}

#pragma mark - Pure Data

extern void fiddle_tilde_setup(void);

- (void)initPd {
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
#if TARGET_IPHONE_SIMULATOR	
	int ticksPerBuffer = 8;  // No other value seems to work with the simulator.
#else
    int ticksPerBuffer = 32;
#endif
    
	pdAudio = [[PdAudio alloc] initWithSampleRate:22050.0 andTicksPerBuffer:ticksPerBuffer
                         andNumberOfInputChannels:2 andNumberOfOutputChannels:2];
	
	[self copyDemoPatchesToUserDomain];  // move the bundled patches to the documents dir
	[self openAndRunTestPatch];
    
    fiddle_tilde_setup();
    
    [PdBase subscribe: @"tick"];
    [PdBase subscribe: @"sampleToSwitchReceived"];
    [PdBase subscribe: @"toPlaytable"];
    [PdBase subscribe: @"currentTimeReceived"];
    [PdBase setDelegate:self];

    [pool drain];
}

- (void) openAndRunTestPatch {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	
//  	[PdBase openFile:@"_Main.pd" path:documentsDirectory];

  	[PdBase openFile:@"/pd/_MainSpecial.pd" path:documentsDirectory];    
    
	[PdBase computeAudio:YES];
	[pdAudio play];
    NSLog(@"openAndRunTestPatch has run");
    
}


- (void) copyDemoPatchesToUserDomain
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSError *fileError;
	
	NSBundle *mainBundle = [NSBundle mainBundle];
	NSString *bundlePath = [mainBundle bundlePath];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    // Declare /pd folder inside Documents directory
    NSString *pdPatchFolder = [documentsDirectory stringByAppendingPathComponent:@"/pd"];
    
    // Create the /pd folder if it doesn't exist already
    if (![[NSFileManager defaultManager] fileExistsAtPath:pdPatchFolder])
        [[NSFileManager defaultManager] createDirectoryAtPath:pdPatchFolder withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
    
    // Specify that the /pd folder should be skipped from iCloud back-up
    [self addSkipBackupAttributeToItemAtURL:[NSURL URLWithString:pdPatchFolder]];
	
	NSArray *bundleFiles = [fm contentsOfDirectoryAtPath:bundlePath error:&fileError];
	
	for( NSString *patchFile in bundleFiles )
	{
		if ([[patchFile pathExtension] isEqualToString:patchFileTypeExtension] ||
            [[patchFile pathExtension] isEqualToString:wavFileTypeExtension] ||
            [[patchFile pathExtension] isEqualToString:cFileTypeExtension]) 
		{
            // Path to the Documents/pd folder
            NSString *pdPatchFolderPath = [NSString stringWithFormat:@"/pd/%@", patchFile];
            
			NSString *bundlePatchFilePath = [bundlePath stringByAppendingPathComponent:patchFile]; 
			NSString *documentsPatchFilePath = [documentsDirectory stringByAppendingPathComponent:pdPatchFolderPath];
                
            NSLog(@"Copying %@ into the documents directory", pdPatchFolderPath);
            
			if ([fm fileExistsAtPath:bundlePatchFilePath]) 
			{
				if( ![fm fileExistsAtPath:documentsPatchFilePath] )
					if( ![fm copyItemAtPath:bundlePatchFilePath toPath: documentsPatchFilePath error:&fileError] )
						NSLog(@"Error copying demo patch:%@", [fileError localizedDescription]);
			} 
		}
	}
}

// Method to assign files and folders to be skipped from iCloud back-up
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    const char* filePath = [[URL path] fileSystemRepresentation];
    
    const char* attrName = "com.apple.MobileBackup";
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    return result == 0;
}

// Receive messages from Pd
- (void)receiveSymbol:(NSString *)symbol fromSource:(NSString *)source {
    // Send this message to the compassClass setCountry method to update UILabel
    NSLog(@"Received new country: %@", symbol);
}

// Receive print messages from Pd
- (void)receivePrint:(NSString *)string {
    NSLog(@"%@", string);
}

// Receive bangs from Pd
- (void)receiveBangFromSource:(NSString *)source{
    NSLog(@"Bang from %@", source);
}

- (void)receiveFloat:(float)received fromSource:(NSString *)source{
    if ([source isEqualToString:@"sampleToSwitchReceived"]) {
        NSLog(@"%f received from %@", received, source);
//        [firstViewController receivedTick:received];
    }
//    NSLog(@"%f received from %@", received, source);
}


#pragma mark - App lifecycle

- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [navigationController release];
    [firstViewController release];
    [window release];
    [super dealloc];
}


@end
