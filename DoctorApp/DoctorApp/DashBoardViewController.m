//
//  DashBoardViewController.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "DashBoardViewController.h"
#import "PatientProfileViewController.h"
#import "DataBaseManager.h"
#import "MyUserDefaults.h"
#import "DashBoardTableViewCell.h"
#import "AppointmentViewController.h"
#import "PrescriptionViewController.h"
#import <Sinch/Sinch.h>
#import "CallViewController.h"

NSString* dateFormat = @"yyyy-MM-dd HH:mm";

@interface DashBoardViewController ()  <SINCallClientDelegate>
@property (nonatomic, strong) NSMutableArray* upcomingAppointmentsTableDataSource;
@property (nonatomic, strong) IBOutlet UITableView* upcomingAppointmentsTable;
@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UIImageView* appointmentImageView;
@property (weak, nonatomic) IBOutlet UIImageView *prescriptionImageView;
@property (nonatomic, strong) IBOutlet UIImageView* homeImageView;
@end

@implementation DashBoardViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.client.callClient.delegate = self;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UserDidLoginNotification"
                                                        object:nil
                                                      userInfo:@{
                                                                 @"userId" : @"userB"
                                                                 }];
    
    UITapGestureRecognizer* profileTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapGesture:)];
    [self.profileImageView addGestureRecognizer:profileTapGestrue];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* appointmentTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appointmentTapGesture:)];
    [self.appointmentImageView addGestureRecognizer:appointmentTapGestrue];
    [self.appointmentImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* prescriptionTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prescriptionTapGesture:)];
    [self.prescriptionImageView addGestureRecognizer:prescriptionTapGesture];
    [self.prescriptionImageView setUserInteractionEnabled:YES];
    
    [self.upcomingAppointmentsTable setSeparatorColor:[self colorFromHexString:@"#8FC7E6"]];
    
    self.upcomingAppointmentsTable.dataSource = self;
    self.upcomingAppointmentsTable.delegate = self;
    
    self.upcomingAppointmentsTableDataSource = [[NSMutableArray alloc] init];
    
    NSString* patientID = [MyUserDefaults retrievePatientId];
    
    [[DataBaseManager sharedInstance] retreivePatientAppointmentWithResponseCallback:^(NSDictionary* appointments){
        
        for (NSString* key in appointments)
        {
            NSDictionary* appointment = [appointments objectForKey:key];
            
            if ([[appointment objectForKey:@"patientID"] isEqualToString:patientID])
            {
                [self.upcomingAppointmentsTableDataSource addObject:appointment];
            }
        }
        
        [self reloadData];
        
    }];
    // Do any additional setup after loading the view from its nib.
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
    [self.upcomingAppointmentsTable reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DashBoardTableViewCell";
    
    NSDictionary* appointment = [self.upcomingAppointmentsTableDataSource objectAtIndex:indexPath.row];
    
    DashBoardTableViewCell* cell = (DashBoardTableViewCell* )[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"DashBoardTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:dateFormat];
    NSDate* date = [dateFormatter dateFromString:[appointment objectForKey:@"date"]];
    
    
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    [dayFormatter setDateFormat:@"EEEE"];
    NSString *dayName = [dayFormatter stringFromDate:date];
    
    NSDateComponents *otherDay = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    NSDateComponents *today = [[NSCalendar currentCalendar] components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
    
    if([today day] == [otherDay day] &&
       [today month] == [otherDay month] &&
       [today year] == [otherDay year] &&
       [today era] == [otherDay era])
    {
       dayName = @"Today";
    }
    
    cell.dayLabel.text = dayName;
    
    
    
    dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"MMMM dd, YYYY"];
    
    cell.dateLabel.text = [dateFormatter stringFromDate:date];
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"hh:mm a"];
    
    cell.timeLabel.text = [formatter stringFromDate:date];
    
    
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.upcomingAppointmentsTable isEqual:tableView])
    {
        return [self.upcomingAppointmentsTableDataSource count];
    }
    return 0;
}

- (void)profileTapGesture:(id)sender
{
    PatientProfileViewController* patientProfileViewController = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
    [self.navigationController pushViewController:patientProfileViewController animated:YES];
}

- (void)appointmentTapGesture:(id)sender
{
    AppointmentViewController* appointmentViewController = [[AppointmentViewController alloc] initWithNibName:@"AppointmentViewController" bundle:nil];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}

- (void)prescriptionTapGesture:(id)sender
{
    PrescriptionViewController* prescriptionViewController = [[PrescriptionViewController alloc] initWithNibName:@"PrescriptionViewController" bundle:nil];
    [self.navigationController pushViewController:prescriptionViewController animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self call];
    
}
- (id<SINClient>)client {
    return [(AppDelegate *)[[UIApplication sharedApplication] delegate] client];
}

- (void)call
{
    if ([self.client isStarted]) {
        id<SINCall> call = [self.client.callClient callUserVideoWithId:@"userA"];
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryBoard" bundle:nil];
        CallViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CallViewController"];
        vc.call = call;
        [self presentViewController:vc animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    CallViewController *callViewController = [segue destinationViewController];
    callViewController.call = sender;
}

#pragma mark - SINCallClientDelegate

- (void)client:(id<SINCallClient>)client didReceiveIncomingCall:(id<SINCall>)call {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    CallViewController *vc = [sb instantiateViewControllerWithIdentifier:@"CallViewController"];
    vc.call = call;
    [self presentViewController:vc animated:YES completion:nil];
}

- (SINLocalNotification *)client:(id<SINClient>)client localNotificationForIncomingCall:(id<SINCall>)call {
    SINLocalNotification *notification = [[SINLocalNotification alloc] init];
    notification.alertAction = @"Answer";
    notification.alertBody = [NSString stringWithFormat:@"Incoming call from %@", [call remoteUserId]];
    return notification;
}


@end
