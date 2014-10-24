//
//  PEViewPhotoViewCollectionViewCell.m
//  Periop
//
//  Created by Kirill on 10/23/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEViewPhotoViewCollectionViewCell.h"

@interface PEViewPhotoViewCollectionViewCell () <UIScrollViewDelegate>

@end

@implementation PEViewPhotoViewCollectionViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.photoScrollView.contentInset = UIEdgeInsetsZero;
    [self configPhotoScrollView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.photoScrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
}

#pragma mark - Private

- (void)configPhotoScrollView
{
    self.photoScrollView.minimumZoomScale = 1.0f;
    self.photoScrollView.maximumZoomScale = 4.0f;
    self.photoScrollView.zoomScale = 1.0f;
    self.photoScrollView.delegate = self;
}

#pragma mark - Public

- (void)centerScrollViewContents
{
    CGSize boundsSize = self.photoScrollView.bounds.size;
    CGRect contentsFrame = self.photoScrollView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.imageViewForSelectedPhoto.frame = contentsFrame;
}

- (void)resizeCell:(UIInterfaceOrientation)toInterfaceOrientation boundsParam:(CGRect)toBounds
{
    CGRect newRect;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        newRect = CGRectMake(0, 0, toBounds.size.height, toBounds.size.width);
    } else {
        newRect = toBounds;
    }
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        CGSize size = CGSizeMake(self.imageViewForSelectedPhoto.image.size.height, self.imageViewForSelectedPhoto.image.size.width);
        size.height = toBounds.size.height;
        size.width = size.width * (size.height / self.imageViewForSelectedPhoto.image.size.width);
        self.imageViewForSelectedPhoto.bounds = CGRectMake(0, 0, size.height, size.width);
        self.photoScrollView.contentSize = CGSizeMake(size.height, size.width);
        //self.bounds = newRect;
        self.photoScrollView.frame = newRect;
    } else {
        CGSize size = self.imageViewForSelectedPhoto.image.size;
        size.height = toBounds.size.width;
        size.width = size.width * (size.height / self.imageViewForSelectedPhoto.image.size.height);
        self.imageViewForSelectedPhoto.bounds = CGRectMake(0, 0, size.width, size.height);
        self.photoScrollView.contentSize = size;
        //self.bounds = newRect;
        self.photoScrollView.frame = newRect;
    }
    [self centerScrollViewContents];
    //self.photoScrollView.zoomScale = 1.0f;
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centerScrollViewContents];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageViewForSelectedPhoto;
}

@end
