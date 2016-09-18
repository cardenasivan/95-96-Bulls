//
//  MyUserDefaults.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "MyUserDefaults.h"

NSString* touchIDKey = @"TouchID_Key";
NSString* passwordKey = @"Password_Key";
NSString* emailKey = @"Email_Key";
NSString* patientIdKey = @"Patient_Key";

@implementation MyUserDefaults

+ (void)allowTouchID
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setBool:YES forKey:touchIDKey];
    }
}

+ (void)disableTouchID
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    if (userDefaults)
    {
        [userDefaults setBool:YES forKey:touchIDKey];
    }
}


+ (BOOL)isTouchIDAllowed
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:touchIDKey];
}


+ (void)storeUserInfo:(NSString*)email patientId:(NSString*)patientId andPassword:(NSString* )password
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    
    if (email)
    {
        [userDefaults setValue:email forKey:emailKey];
    }
    
    if (patientId)
    {
        [userDefaults setValue:patientId forKey:patientIdKey];
    }
    
    if (password)
    {
        [userDefaults setValue:password forKey:passwordKey];
    }
    
}

+ (NSString* )retrieveEmail
{
     NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:emailKey];
}

+ (NSString* )retrievePatientId
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:patientIdKey];
}

+ (NSString* )retrievePassword
{
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults valueForKey:passwordKey];
}


@end
