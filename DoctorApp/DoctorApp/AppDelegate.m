//
//  AppDelegate.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/16/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self handleLocalNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]];
    [self requestUserNotificationPermission];
    [[NSNotificationCenter defaultCenter] addObserverForName:@"UserDidLoginNotification"
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *note) {
                                                      [self initSinchClientWithUserId:note.userInfo[@"userId"]];
                                                  }];
    // Override point for customization after application launch.
    [FIRApp configure];
    
    LoginViewController* loginViewController = [[LoginViewController alloc] initWithNibName:@"LoginViewController" bundle:nil];
    
    UINavigationController* navController = [[UINavigationController alloc] initWithRootViewController:loginViewController];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    self.window.rootViewController = navController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [self handleLocalNotification:notification];
}

- (void)requestUserNotificationPermission {
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType types = UIUserNotificationTypeAlert | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
}

#pragma mark -

- (void)initSinchClientWithUserId:(NSString *)userId {
    if (!self.client) {
        self.client = [Sinch clientWithApplicationKey:@"f0cdfe61-69ba-4a98-b024-a623ae884bf5"
                                applicationSecret:@"Hu3OWcgiF023ZIj2P7P3pw=="
                                  environmentHost:@"sandbox.sinch.com"
                                           userId:userId];
        
        self.client.delegate = self;
        
        [self.client setSupportCalling:YES];
        [self.client setSupportActiveConnectionInBackground:YES];
        
        [self.client start];
        [self.client startListeningOnActiveConnection];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)handleLocalNotification:(UILocalNotification *)notification {
    if (notification) {
        id<SINNotificationResult> result = [self.client relayLocalNotification:notification];
        if ([result isCall] && [[result callResult] isTimedOut]) {
            UIAlertView *alert = [[UIAlertView alloc]
                                  initWithTitle:@"Missed call"
                                  message:[NSString stringWithFormat:@"Missed call from %@", [[result callResult] remoteUserId]]
                                  delegate:nil
                                  cancelButtonTitle:nil
                                  otherButtonTitles:@"OK", nil];
            [alert show];
        }
    }
}

#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Sinch client started successfully (version: %@)", [Sinch version]);
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Sinch client error: %@", [error localizedDescription]);
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
    if (severity == SINLogSeverityCritical) {
        NSLog(@"%@", message);
    }
}


@end
