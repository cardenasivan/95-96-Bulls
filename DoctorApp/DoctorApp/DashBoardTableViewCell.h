//
//  DashBoardTableViewCell.h
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DashBoardTableViewCell : UITableViewCell

@property(nonatomic, strong) IBOutlet UIButton* webCamButton;
@property(nonatomic, strong) IBOutlet UILabel* dayLabel;
@property(nonatomic, strong) IBOutlet UILabel* dateLabel;
@property(nonatomic, strong) IBOutlet UILabel* timeLabel;

@end
