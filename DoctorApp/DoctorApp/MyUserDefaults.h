//
//  MyUserDefaults.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MyUserDefaults : NSData

+ (void)allowTouchID;
+ (BOOL)isTouchIDAllowed;
+ (void)disableTouchID;
+ (void)storeUserInfo:(NSString*)email patientId:(NSString*)patientId andPassword:(NSString* )password;
+ (NSString* )retrieveEmail;
+ (NSString* )retrievePatientId;
+ (NSString* )retrievePassword;

@end
