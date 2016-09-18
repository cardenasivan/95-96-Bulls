//
//  AppDelegate.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/16/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Sinch/Sinch.h>
@import Firebase;


@interface AppDelegate : UIResponder <UIApplicationDelegate, SINClientDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) id<SINClient> client;

@end

