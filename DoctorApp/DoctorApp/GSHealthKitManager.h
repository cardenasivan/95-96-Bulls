//
//  GSHealthKitManager.h
//  DoctorApp
//
//  Created by ADMINISTRATOR on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#ifndef GSHealthKitManager_h
#define GSHealthKitManager_h

@interface GSHealthKitManager : NSObject

+ (GSHealthKitManager *)sharedManager;

- (void)requestAuthorization;
-(void)readHeartRateWithCompletion:(void (^)(NSArray *results, NSError *error))completion;
-(void)queryHealthDataHeart;
@end

#endif /* GSHealthKitManager_h */
#import <UIKit/UIKit.h>
