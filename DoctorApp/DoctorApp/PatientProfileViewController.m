//
//  PatientProfileViewController.m
//  DoctorApp
//
//  Created by ADMINISTRATOR on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "PatientProfileViewController.h"
#import "AppointmentViewController.h"
#import "DashBoardViewController.h"
#import "PrescriptionViewController.h"
#import "MyUserDefaults.h"

@interface PatientProfileViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *patientIDLabel;

@property (weak, nonatomic) IBOutlet UIImageView *appointmentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *homeImageView;
@property (weak, nonatomic) IBOutlet UIImageView *prescriptionImageView;
@property (weak, nonatomic) IBOutlet UITextField *addressOneField;
@property (weak, nonatomic) IBOutlet UITextField *cityField;
@property (weak, nonatomic) IBOutlet UITextField *zipField;
@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *stateField;
@property (weak, nonatomic) IBOutlet UIButton *hrButton;
@property (weak, nonatomic) IBOutlet UILabel *hrLabel;

@end

@implementation PatientProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.addressOneField.delegate = self;
    self.cityField.delegate = self;
    self.zipField.delegate = self;
    self.phoneField.delegate = self;
    self.emailField.delegate = self;
    self.stateField.delegate = self;
    
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
    
    UITapGestureRecognizer* appointmentTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appointmentTapGesture:)];
    [self.appointmentImageView addGestureRecognizer:appointmentTapGestrue];
    [self.appointmentImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* homeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeTapGesture:)];
    [self.homeImageView addGestureRecognizer:homeTapGesture];
    [self.homeImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* prescriptionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prescriptionTapGesture:)];
    [self.prescriptionImageView addGestureRecognizer:prescriptionTapGesture];
    [self.prescriptionImageView setUserInteractionEnabled:YES];
    
    [self requestPatientData];
    _patientIDLabel.text = [MyUserDefaults retrievePatientId];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)requestPatientData {
    NSString *patientURL = [@"https://fhir-open-api-dstu2.smarthealthit.org/Patient/" stringByAppendingString:[MyUserDefaults retrievePatientId]];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:patientURL]];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {

        if (!error) {
            NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
            
            if(404 == [httpResponse statusCode]){
                [self newFhirUser:patientURL];
            } else {
            
                NSError* jsonError;
                NSDictionary* json = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &jsonError];
                
                // update the UI here (and only here to the extent it depends on the json)
            
                if([json objectForKey:@"address"] != nil){
                    NSArray *address = [json objectForKey:@"address"];
                    
                    for (NSDictionary* dict in address) {
                        
                        for(NSString* key in dict)
                        {
                            NSString* value = [dict valueForKey:key];
                            
                            if([key isEqualToString:@"line"]){
                                _addressOneField.text = value;
                            } else if([key isEqualToString:@"address-city"]){
                                _cityField.text = value;
                            } else if([key isEqualToString:@"address-postalcode"]){
                                _zipField.text = value;
                            } else if([key isEqualToString:@"address-state"]){
                                _stateField.text = value;
                            }
                            
                        }
                        
                    }
                }
                
                if([json objectForKey:@"telecom"] != nil){
                    NSArray *telecom = [json objectForKey:@"telecom"];
                    for(NSDictionary* dict in telecom){
                        for(NSString*  key in dict){
                            NSString* value = [dict valueForKey:key];
                            
                            if([key isEqualToString:@"system"] && [value isEqualToString:@"email"]){
                                _emailField.text = [dict objectForKey:@"value"];
                            } else if([key isEqualToString:@"system"] && [value isEqualToString:@"phone"]){
                                _phoneField.text = [dict objectForKey:@"value"];
                            }
                        }
                    }
                }
                
                //name = [json objectForKey:@"name"];
                //gender = [json objectForKey:@"gender"];
                //dob = [json objectForKey:@"birthdate"];
            }
        } else {
            //[self newFhirUser:request];
        }
    }];
}

- (void)newFhirUser:(NSString*) patientURL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:patientURL]];
    
    NSMutableDictionary *newUser = [NSMutableDictionary new];
    [newUser setObject:@"Patient" forKey:@"resourceType"];
    [newUser setObject:[MyUserDefaults retrievePatientId] forKey:@"id"];
    
    NSMutableDictionary* telcomVal = [[NSMutableDictionary alloc] init];
    
    [telcomVal setObject:@"email" forKey:@"system"];
    
    [telcomVal setObject:[MyUserDefaults retrieveEmail] forKey:@"value"];
    
    NSArray *telcomArray = [NSArray arrayWithObject:telcomVal];

    [newUser setObject:telcomArray forKey:@"telecom"];
    
    
    NSError* error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:newUser options:0 error: &error];
    
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (!error) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               }
    }];
    
}
                            
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)saveProfile:(UIButton *)sender
{
    NSMutableDictionary *jsonToPost = [NSMutableDictionary new];
    
    NSMutableDictionary* addressVal = [[NSMutableDictionary alloc] init];
    NSMutableArray* addressLines = [[NSMutableArray alloc] init];
    [addressLines addObject:_addressOneField.text];
    [addressVal setObject:addressLines forKey:@"line"];
    [addressVal setObject:_cityField.text forKey:@"city"];
    [addressVal setObject:_zipField.text forKey:@"postalcode"];
    [addressVal setObject:_stateField.text forKey:@"state"];
    NSArray *addressArray = [NSArray arrayWithObject:addressVal];
    
    [jsonToPost setObject:addressArray forKey:@"address"];
    
    
    NSMutableDictionary* telcomVal = [[NSMutableDictionary alloc] init];
    [telcomVal setObject:@"phone" forKey:@"system"];
    [telcomVal setObject:_phoneField.text forKey:@"value"];
    NSArray *telcomArray = [NSArray arrayWithObject:telcomVal];
    
    [jsonToPost setObject:telcomArray forKey:@"telecom"];
    
    //[jsonToPost setObject:gender.text forKey:@"gender"];
    //[jsonToPost setObject:dob.text forKey:@"birthdate"];
    
    NSString *patientURL = [@"https://fhir-open-api-dstu2.smarthealthit.org/Patient/" stringByAppendingString:[MyUserDefaults retrievePatientId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:patientURL]];
    
    NSError* error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:jsonToPost options:0 error: &error];
    [request setHTTPMethod:@"PUT"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
    [request setHTTPBody:postData];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               
                               if (!error) {
                                   NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
                               }
                           }];
    
}

- (void)appointmentTapGesture:(id)sender
{
    AppointmentViewController* appointmentViewController = [[AppointmentViewController alloc] initWithNibName:@"AppointmentViewController" bundle:nil];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}

- (void)homeTapGesture:(id)sender
{
    DashBoardViewController* dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    [self.navigationController pushViewController:dashBoardViewController animated:YES];
}

- (void)prescriptionTapGesture:(id)sender
{
    PrescriptionViewController* prescriptionViewController = [[PrescriptionViewController alloc] initWithNibName:@"PrescriptionViewController" bundle:nil];
    [self.navigationController pushViewController:prescriptionViewController animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return true;
}
@end
