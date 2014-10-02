//
//  PEOperationTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/30/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEOperationTableViewCell.h"

@implementation PEOperationTableViewCell

#pragma mark - LifeCycle

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.labelStep.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
    self.labelPreparationText.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
}

@end
