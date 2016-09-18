//
//  PrescriptionLocationViewController.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface PrescriptionLocationViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@end
