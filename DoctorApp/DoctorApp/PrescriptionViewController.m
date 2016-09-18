//
//  PrescriptionViewController.m
//  DoctorApp
//
//  Created by ADMINISTRATOR on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "PrescriptionViewController.h"
#import "PatientProfileViewController.h"
#import "AppointmentViewController.h"
#import "DashBoardViewController.h"
#import "MyUserDefaults.h"
#import "DataBaseManager.h"
#import "PrescriptionTableViewCell.h"
#import "PrescriptionLocationViewController.h"

NSString* prescriptionDateFormat = @"yyyy-MM-dd HH:mm";

@interface PrescriptionViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *appointmentImageView;
@property (strong, nonatomic) IBOutlet UIImageView *homeImageView;
@property (strong, nonatomic) IBOutlet UIImageView *profileImageView;
@property (strong, nonatomic) IBOutlet UITableView *prescriptionTableView;
@property (strong, nonatomic) IBOutlet UILabel* locationName;
@property (strong, nonatomic) IBOutlet UILabel* locationAddress;
@property (strong, nonatomic) NSMutableArray* dataSource;
@property (strong, nonatomic) NSDictionary* locationDictionary;

@end

@implementation PrescriptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UITapGestureRecognizer* profileTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapGesture:)];
    [self.profileImageView addGestureRecognizer:profileTapGestrue];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* appointmentTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appointmentTapGesture:)];
    [self.appointmentImageView addGestureRecognizer:appointmentTapGestrue];
    [self.appointmentImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* homeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeTapGesture:)];
    [self.homeImageView addGestureRecognizer:homeTapGesture];
    [self.homeImageView setUserInteractionEnabled:YES];
    
    self.prescriptionTableView.dataSource = self;
    self.prescriptionTableView.delegate = self;
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    [self.prescriptionTableView setSeparatorColor:[self colorFromHexString:@"#8FC7E6"]];
    
    NSString* patientID = [MyUserDefaults retrievePatientId];
    
    [[DataBaseManager sharedInstance] retreivePrescriptionsWithResponseCallback:^(NSDictionary* prescriptions){
        
        for (NSString* key in prescriptions)
        {
            NSDictionary* appointment = [prescriptions objectForKey:key];
            
            if ([[appointment objectForKey:@"patientID"] isEqualToString:patientID])
            {
                [self.dataSource addObject:appointment];
            }
        }
        
        [self reloadData];
        
    }];
    
    [[DataBaseManager sharedInstance] retreiveLocationWithResponseCallback:^(NSDictionary* locationDictionary) {
        
        for (NSString* key in locationDictionary)
        {
            NSDictionary* location = [locationDictionary objectForKey:key];
            
            if ([[location objectForKey:@"patientID"] isEqualToString:patientID])
            {
                self.locationDictionary = location;
                break;
            }
        }
        
        [self setLocationTextFields];
        
    }];
    // Do any additional setup after loading the view from its nib.
}

- (void)setLocationTextFields
{
    NSString* locationName = [self.locationDictionary objectForKey:@"name"];
    NSString* locationAddress = [self.locationDictionary objectForKey:@"address"];
    
    self.locationName.text = locationName;
    self.locationAddress.text = locationAddress;
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

- (void)reloadData
{
    [self.prescriptionTableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DashBoardTableViewCell";
    
    NSDictionary* prescription = [self.dataSource objectAtIndex:indexPath.row];
    
    PrescriptionTableViewCell* cell = (PrescriptionTableViewCell* )[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrescriptionTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:prescriptionDateFormat];
    NSDate* date = [dateFormatter dateFromString:[prescription objectForKey:@"date"]];
    
    
    
    cell.prescription.text = [prescription objectForKey:@"medicine"];
    
    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
    
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    cell.timeLabel.text = [formatter stringFromDate:date];
    
    
    return cell;
    
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

- (void)profileTapGesture:(id)sender
{
    PatientProfileViewController* patientProfileViewController = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
    [self.navigationController pushViewController:patientProfileViewController animated:YES];
}

- (IBAction)selectNewLocation:(id)sender
{
    PrescriptionLocationViewController* prescriptionLocationViewController = [[PrescriptionLocationViewController alloc] initWithNibName:@"PrescriptionLocationViewController" bundle:nil];
    
    [self.navigationController pushViewController:prescriptionLocationViewController animated:YES];
}

@end
