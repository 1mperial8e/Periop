//
//  PEViewPhotoViewCollectionViewCell.h
//  Periop
//
//  Created by Kirill on 10/23/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PEViewPhotoViewCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIScrollView *photoScrollView;

@property (strong, nonatomic) UIImageView *imageViewForSelectedPhoto;

- (void)centerScrollViewContents;
- (void)resizeCell:(UIInterfaceOrientation)toInterfaceOrientation boundsParam:(CGRect)toBounds;


@end
