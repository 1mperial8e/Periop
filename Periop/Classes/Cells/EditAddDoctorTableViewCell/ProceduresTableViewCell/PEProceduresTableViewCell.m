//
//  PEProceduresTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEProceduresTableViewCell.h"

@implementation PEProceduresTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    self.procedureName.font = [UIFont fontWithName:@"MuseoSans-300" size:17.5f];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.checkButton.selected = self.selected;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.checkButton.selected = selected;
}

@end
