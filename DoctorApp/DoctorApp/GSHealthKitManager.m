//
//  GSHealthKitManager.m
//  DoctorApp
//
//  Created by ADMINISTRATOR on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSHealthKitManager.h"
#import "HealthKit/HealthKit.h"
@interface GSHealthKitManager ()

@property (nonatomic, retain) HKHealthStore *healthStore;

@end


@implementation GSHealthKitManager

+ (GSHealthKitManager *)sharedManager {
    static dispatch_once_t pred = 0;
    static GSHealthKitManager *instance = nil;
    dispatch_once(&pred, ^{
        instance = [[GSHealthKitManager alloc] init];
        instance.healthStore = [[HKHealthStore alloc] init];
    });
    return instance;
}

- (void)requestAuthorization {
    
    if ([HKHealthStore isHealthDataAvailable] == NO) {
        // If our device doesn't support HealthKit -> return.
        return;
    }
    
    NSArray *readTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
    
    NSArray *writeTypes = @[[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]];
    
    [self.healthStore requestAuthorizationToShareTypes:[NSSet setWithArray:readTypes]
                                             readTypes:[NSSet setWithArray:readTypes] completion:nil];
}


- (void)readHeartRateWithCompletion:(void (^)(NSArray *results, NSError *error))completion {
    [self requestAuthorization];
    //get the heart rates
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:now];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    
    NSDate *beginOfDay = [calendar dateFromComponents:components];
    NSPredicate *predicate = [HKSampleQuery predicateForSamplesWithStartDate:beginOfDay endDate:now options:HKQueryOptionStrictStartDate];
    
    HKSampleType *sampleType = [HKSampleType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    NSSortDescriptor *lastDateDescriptor = [[NSSortDescriptor alloc]
                                            
                                            initWithKey:HKSampleSortIdentifierStartDate ascending:YES selector:@selector(localizedStandardCompare:)];
    NSArray *sortDescriptors = @[lastDateDescriptor];
    
    HKSampleQuery *query = [[HKSampleQuery alloc] initWithSampleType:sampleType predicate:predicate limit:HKObjectQueryNoLimit sortDescriptors:sortDescriptors resultsHandler:^(HKSampleQuery *query, NSArray *results, NSError *error){
        if (!results) {
            NSLog(@"An error occured fetching the user's heartrate. The error was: %@.", error);
            //abort();
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            NSMutableArray *arrayHeartRate = [[NSMutableArray alloc]init];
            
            for (HKQuantitySample *sample in results) {
                double hbpm = [sample.quantity doubleValueForUnit:[[HKUnit countUnit] unitDividedByUnit:[HKUnit minuteUnit]]];
                [arrayHeartRate addObject:[NSNumber numberWithDouble:hbpm]];
            }
            
            if (completion != nil) {
                completion(arrayHeartRate, error);
            }
        });
    }];
    [self.healthStore executeQuery:query];
}
@end
