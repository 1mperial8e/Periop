//
//  PESpecialisationCollectionViewCell.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESpecialisationCollectionViewCell.h"

@implementation PESpecialisationCollectionViewCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.labelPrice.text = @"";
}

@end
