//
//  PEDoctorsProfileTableViewCell.m
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDoctorsProfileTableViewCell.h"

@implementation PEDoctorsProfileTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.procedureNameLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:17.5f];
}

@end
