//
//  PECollectionViewCellItemCell.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PECollectionViewCellItemCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *inactiveImageViewWithLogo;
@property (weak, nonatomic) IBOutlet UIImageView *activeImageViewWithLogo;
@property (weak, nonatomic) IBOutlet UILabel *labelNameOfSpec;

@end
