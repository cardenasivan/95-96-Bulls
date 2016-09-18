//
//  DashBoardTableViewCell.m
//  DoctorApp
//
//  Created by Ivan Cardenas on 9/17/16.
//  Copyright © 2016 Ivan Cardenas. All rights reserved.
//

#import "DashBoardTableViewCell.h"

@implementation DashBoardTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    // Initialization code
    self.webCamButton.contentMode = UIViewContentModeScaleAspectFit;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
