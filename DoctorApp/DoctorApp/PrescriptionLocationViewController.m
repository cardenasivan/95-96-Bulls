//
//  PrescriptionLocationViewController.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "PrescriptionLocationViewController.h"
#import "PatientProfileViewController.h"
#import "DashBoardViewController.h"
#import "DashBoardTableViewCell.h"
#import "PrescriptionViewController.h"
#import "DataBaseManager.h"
#import "MyUserDefaults.h"
#import "ScheduleAlertViewController.h"
#import "AppointmentViewController.h"
#import "PrescriptionTableViewCell.h"


@interface PrescriptionLocationViewController ()
@property (nonatomic, strong) IBOutlet MKMapView* mapView;
@property (nonatomic, strong) CLLocationManager* locationManager;
@property (nonatomic, strong) IBOutlet UIImageView* profileImageView;
@property (nonatomic, strong) IBOutlet UIImageView* appointmentImageView;
@property (nonatomic, strong) IBOutlet UIImageView *prescriptionImageView;
@property (nonatomic, strong) IBOutlet UIImageView* homeImageView;
@property (nonatomic, strong) IBOutlet UITableView* tableView;
@property (nonatomic, strong) NSArray* dataSource;
@end

@implementation PrescriptionLocationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    UITapGestureRecognizer* tapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(profileTapGesture:)];
    [self.profileImageView addGestureRecognizer:tapGestrue];
    [self.profileImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* appointmentTapGestrue = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(appointmentTapGesture:)];
    [self.appointmentImageView addGestureRecognizer:appointmentTapGestrue];
    [self.appointmentImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* homeTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(homeTapGesture:)];
    [self.homeImageView addGestureRecognizer:homeTapGesture];
    [self.homeImageView setUserInteractionEnabled:YES];
    
    UITapGestureRecognizer* prescriptonTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(prescriptionTapGesture:)];
    [self.prescriptionImageView addGestureRecognizer:prescriptonTapGesture];
    [self.prescriptionImageView setUserInteractionEnabled:YES];
    
    self.mapView.delegate = self;


    [self.mapView setShowsUserLocation:YES];
    
    [self searchLocations];

    // Do any additional setup after loading the view from its nib.
}

- (void)mapView:(MKMapView *)mv didAddAnnotationViews:(NSArray *)views
{
    MKAnnotationView *annotationView = [views objectAtIndex:0];

    id<MKAnnotation> mp = [annotationView annotation];

    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance([mp coordinate] ,250,250);

    [mv setRegion:region animated:YES];
}

- (void)searchLocations
{
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"pharmacy";
    request.region = self.mapView.region;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        
        NSMutableArray *annotations = [NSMutableArray array];
        
        [response.mapItems enumerateObjectsUsingBlock:^(MKMapItem *item, NSUInteger idx, BOOL *stop) {
            MKPlacemark *annotation = [[MKPlacemark alloc] initWithPlacemark:item.placemark];
            [annotations addObject:annotation];
        }];
        
        self.dataSource = annotations;
        
        [self.tableView reloadData];
        
        [self.mapView addAnnotations:annotations];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                                       reuseIdentifier:@"CustomAnnotationView"];
    annotationView.canShowCallout = YES;
    annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return annotationView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)profileTapGesture:(id)sender
{
    PatientProfileViewController* patientProfileViewController = [[PatientProfileViewController alloc] initWithNibName:@"PatientProfileViewController" bundle:nil];
    [self.navigationController pushViewController:patientProfileViewController animated:YES];
}

- (void)prescriptionTapGesture:(id)sender
{
    PrescriptionViewController* prescriptionViewController = [[PrescriptionViewController alloc] initWithNibName:@"PrescriptionViewController" bundle:nil];
    [self.navigationController pushViewController:prescriptionViewController animated:YES];
}

- (void)homeTapGesture:(id)sender
{
    DashBoardViewController* dashBoardViewController = [[DashBoardViewController alloc] initWithNibName:@"DashBoardViewController" bundle:nil];
    [self.navigationController pushViewController:dashBoardViewController animated:YES];
}

- (void)appointmentTapGesture:(id)sender
{
    AppointmentViewController* appointmentViewController = [[AppointmentViewController alloc] initWithNibName:@"AppointmentViewController" bundle:nil];
    [self.navigationController pushViewController:appointmentViewController animated:YES];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.dataSource count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"DashBoardTableViewCell";
    NSDictionary* dic =  [[self.dataSource objectAtIndex:indexPath.row] addressDictionary];
    
    NSString* name = [dic objectForKey:@"Name"];
    
    NSString* street = [dic objectForKey:@"Street"];
    
    NSString* state = [dic objectForKey:@"State"];
    
    NSString* city = [dic objectForKey:@"City"];
    
    PrescriptionTableViewCell* cell = (PrescriptionTableViewCell* )[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"PrescriptionTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
    cell.prescription.text = name;
    cell.dateLabel.text = street;
    cell.timeLabel.text = [NSString stringWithFormat:@"%@, %@", city, state];
    [cell.imageView setHidden:YES];
    
    return cell;
}


@end
