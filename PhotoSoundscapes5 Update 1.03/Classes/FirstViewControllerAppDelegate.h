//
//  FirstViewControllerAppDelegate.h
//  FirstViewController
//
//  Created by Adam Greenberg on 09/08/2010.
//  Copyright abgapps - abgapps.co.uk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PdAudio.h"
#import "PSCore.h"
#include <sys/xattr.h>
#import <CoreLocation/CoreLocation.h>

@class FirstViewController;

@interface FirstViewControllerAppDelegate : NSObject <UIApplicationDelegate, PdReceiverDelegate, CLLocationManagerDelegate> {
    UIWindow *window;
    UINavigationController *navigationController;
	PdAudio *pdAudio;
    PSCore *core;
    FirstViewController *firstViewController;
    
    BOOL pdPlaying;
    
    CLLocationManager   *locationManager;
    CLLocation          *startingPoint;
    
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) PSCore *core;
@property (nonatomic, retain) CLLocationManager             *locationManager;
@property (nonatomic, retain) CLLocation                    *startingPoint;

- (void)startUpdatingLocation;
- (void)stopUpdatingLocation;
- (void)openAndRunTestPatch;
- (void)initPd;
- (void)initTimeForPd;
- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL;
@end

