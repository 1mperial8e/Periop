//
//  PECollectionViewCellItemCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PECollectionViewCellItemCell.h"

@implementation PECollectionViewCellItemCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.activeImageViewWithLogo.hidden = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.activeImageViewWithLogo.hidden = !selected;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.labelNameOfSpec.adjustsFontSizeToFitWidth = YES;
}

@end
