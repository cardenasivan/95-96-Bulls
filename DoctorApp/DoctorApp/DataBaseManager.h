//
//  DataBaseManager.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <Foundation/Foundation.h>


@import Firebase;

@interface DataBaseManager : NSData

@property(nonatomic, strong) FIRDatabaseReference* ref;


+(DataBaseManager* )sharedInstance;
- (void)retreivePatientInfoAndUpdateWithEmail:(NSString*)email patientId:(NSString*)patientId;
- (void)retreivePatientAppointmentWithResponseCallback:(void (^)(NSDictionary* appointmentDictionary))callback;
- (void)addAppointmentWithDate:(NSString*)date;
- (void)retreivePrescriptionsWithResponseCallback:(void (^)(NSDictionary* prescriptionDictionary))callback;
- (void)retreiveLocationWithResponseCallback:(void (^)(NSDictionary* locationDictionary))callback;
@end
