//
//  TwitterController.h
//  ExpandViewTransitions
//
//  Created by Yuli A Levtov on 11/01/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SA_OAuthTwitterController.h"
#import "PSCore.h"

@class SA_OAuthTwitterEngine; 

@interface TwitterController : UIViewController <SA_OAuthTwitterControllerDelegate> {
    
    SA_OAuthTwitterEngine    *_engine;
    
}

+ (TwitterController *)twitterController;

- (void)authorizeTwitter;
- (void)logoutFromTwitter;
- (void)twitterTestMethod;

@end