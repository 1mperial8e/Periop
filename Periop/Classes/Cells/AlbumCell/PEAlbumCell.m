//
//  PEAlbumCell.m
//  Periop
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAlbumCell.h"

@implementation PEAlbumCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.selecionImage.hidden = !self.selected;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.selecionImage.hidden = !selected;
}

@end
