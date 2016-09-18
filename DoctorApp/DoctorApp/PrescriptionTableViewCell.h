//
//  PrescriptionTableViewCell.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/18/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrescriptionTableViewCell : UITableViewCell
@property(nonatomic, strong) IBOutlet UIImageView* imageView;
@property(nonatomic, strong) IBOutlet UILabel* prescription;
@property(nonatomic, strong) IBOutlet UILabel* dateLabel;
@property(nonatomic, strong) IBOutlet UILabel* timeLabel;
@end
