//
//  PESpecialisationCollectionViewCell.m
//  Periop
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
    self.labelPrice.font = [UIFont fontWithName:FONT_MuseoSans700 size:20.0f];
}

@end
