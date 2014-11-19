//
//  PESpecialisationCollectionViewCell.m
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESpecialisationCollectionViewCell.h"

@implementation PESpecialisationCollectionViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.labelPrice.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
}

@end
