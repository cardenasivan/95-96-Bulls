//
//  DataBaseManager.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "DataBaseManager.h"
#import "MyUserDefaults.h"
@import Firebase;

@interface DataBaseManager ()

@end

static DataBaseManager* sDataBaseManager = nil;

@implementation DataBaseManager

+ (DataBaseManager* )sharedInstance
{
    if (sDataBaseManager == nil)
    {
        sDataBaseManager = [[DataBaseManager alloc] init];
    }
    return sDataBaseManager;
}

- (FIRDatabaseReference*)ref
{
    if (_ref == nil)
    {
        _ref = [[FIRDatabase database] reference];
    }
    return _ref;
}

- (void)retreivePatientInfoAndUpdateWithEmail:(NSString*)email patientId:(NSString*)patientId
{
    [[self.ref child:@"patients"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        
        NSDictionary* patients = snapshot.value;
        
        
        BOOL containsPatient = NO;
        
        if ([patients count] > 0)
        {
            for (NSString* key in patients)
            {
                NSDictionary* patient = [patients objectForKey:key];
                if ([[patient objectForKey:@"email"] isEqualToString:email] && [[patient objectForKey:@"patientID"] isEqualToString:patientId])
                {
                    containsPatient = YES;
                }
            }
        }
        
        if (!containsPatient)
        {
            NSString *key = [[_ref child:@"patients"] childByAutoId].key;
            NSDictionary *post = @{@"email": email,
                                   @"patientID": patientId};
            
            NSDictionary *childUpdates = @{[@"/patients/" stringByAppendingString:key]: post,
                                           [NSString stringWithFormat:@"%@", key]: post};
            [_ref updateChildValues:childUpdates];

        }
        
        // ...
    } withCancelBlock:^(NSError * _Nonnull error)
    {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)retreivePatientAppointmentWithResponseCallback:(void (^)(NSDictionary* appointmentDictionary))callback
{
    [[self.ref child:@"appointments"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        
        NSDictionary* appointments = snapshot.value;
        
        callback(appointments);
        

    } withCancelBlock:^(NSError * _Nonnull error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
}

- (void)addAppointmentWithDate:(NSString*)date
{
    NSString *key = [[_ref child:@"appointments"] childByAutoId].key;
    NSDictionary *post = @{@"date": date,
                           @"patientID": [MyUserDefaults retrievePatientId]};
    
    NSDictionary *childUpdates = @{[@"/appointments/" stringByAppendingString:key]: post,
                                   [NSString stringWithFormat:@"%@", key]: post};
    [_ref updateChildValues:childUpdates];
}


- (void)retreivePrescriptionsWithResponseCallback:(void (^)(NSDictionary* prescriptionDictionary))callback
{
    [[self.ref child:@"prescriptions"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        
        NSDictionary* prescription = snapshot.value;
        
        callback(prescription);
        
        
    } withCancelBlock:^(NSError * _Nonnull error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
}

- (void)retreiveLocationWithResponseCallback:(void (^)(NSDictionary* locationDictionary))callback
{
    [[self.ref child:@"locations"] observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        // Get user value
        
        NSDictionary* locations = snapshot.value;
        
        callback(locations);
        
        
    } withCancelBlock:^(NSError * _Nonnull error)
     {
         NSLog(@"%@", error.localizedDescription);
     }];
}



@end
