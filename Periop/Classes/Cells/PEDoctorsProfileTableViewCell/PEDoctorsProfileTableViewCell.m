//
//  PEDoctorsProfileTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDoctorsProfileTableViewCell.h"

@implementation PEDoctorsProfileTableViewCell

- (void)awakeFromNib
{
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.minimumScaleFactor = 0.5;
}

@end
