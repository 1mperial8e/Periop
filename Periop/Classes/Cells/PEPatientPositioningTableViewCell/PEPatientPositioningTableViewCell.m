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
    [super awakeFromNib];
    self.labelStepName.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.labelContent.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
}

@end
