//
//  PEPatientPositioningTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/29/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPatientPositioningTableViewCell.h"

@implementation PEPatientPositioningTableViewCell

- (void)awakeFromNib
{
    self.labelStepName.font = [UIFont fontWithName:@"MuseoSans_700.otf" size:17.5f];
    self.labelContent.font = [UIFont fontWithName:@"MuseoSans-300.otf" size:13.5f];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
