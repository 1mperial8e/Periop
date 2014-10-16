//
//  PEProcedureListTableViewCell.m
//  Periop
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEProcedureListTableViewCell.h"

@implementation PEProcedureListTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapPress)];
    [self.labelProcedureName addGestureRecognizer:longPressRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - IBActions

- (void)longTapPress
{
    [self.delegate longPressRecognised:self];
}


@end
