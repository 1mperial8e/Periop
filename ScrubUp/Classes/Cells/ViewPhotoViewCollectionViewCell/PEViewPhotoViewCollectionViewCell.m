//
//  PEViewPhotoViewCollectionViewCell.m
//  ScrubUp
//
//  Created by Kirill on 10/23/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEViewPhotoViewCollectionViewCell.h"

@interface PEViewPhotoViewCollectionViewCell () <UIScrollViewDelegate>

@property (assign, nonatomic) CGPoint contentOffset;

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
    self.photoScrollView.zoomScale = self.photoScrollView.zoomScale;
    CGPoint offset;
    CGSize boundsSize = self.photoScrollView.bounds.size;
    CGRect contentsFrame = self.imageViewForSelectedPhoto.frame;
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
        offset.x = self.photoScrollView.contentSize.width * self.contentOffset.x;
        if (self.photoScrollView.contentSize.width - offset.x < self.photoScrollView.bounds.size.width) {
            offset.x = self.photoScrollView.contentSize.width - self.photoScrollView.bounds.size.width;
        }
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
        offset.y = self.photoScrollView.contentSize.height * self.contentOffset.y;
        if (self.photoScrollView.contentSize.height - offset.y < self.photoScrollView.bounds.size.height) {
            offset.y = self.photoScrollView.contentSize.height - self.photoScrollView.bounds.size.height;
        }
    }
    self.imageViewForSelectedPhoto.frame = contentsFrame;
    
    if (!CGPointEqualToPoint(self.contentOffset, CGPointZero)) {
//        self.photoScrollView.contentOffset = offset;
    }
    self.contentOffset = CGPointZero;
    
//    self.imageViewForSelectedPhoto.center = self.photoScrollView.center;

}

- (void)resizeCell:(UIInterfaceOrientation)toInterfaceOrientation boundsParam:(CGRect)toBounds
{
    CGPoint offset = self.photoScrollView.contentOffset;
    offset.x = offset.x / self.photoScrollView.contentSize.width;
    offset.y = offset.y / self.photoScrollView.contentSize.height;
    self.contentOffset = offset;
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation))
    {
        CGSize size = CGSizeMake(self.imageViewForSelectedPhoto.image.size.width, self.imageViewForSelectedPhoto.image.size.height);
        size.width = toBounds.size.width;
        size.height = size.height * (size.width / self.imageViewForSelectedPhoto.image.size.width);
        self.imageViewForSelectedPhoto.bounds = CGRectMake(0, 0, size.width, size.height);
        self.photoScrollView.contentSize = CGSizeMake(size.width, size.height);
        self.photoScrollView.frame = toBounds;
    } else {
        CGSize size = self.imageViewForSelectedPhoto.image.size;
        size.height = toBounds.size.height ;
        size.width = size.width * (size.height / self.imageViewForSelectedPhoto.image.size.height);
        self.imageViewForSelectedPhoto.bounds = CGRectMake(0, 0, size.width, size.height);
        self.photoScrollView.contentSize = size;
        self.photoScrollView.frame = toBounds;
    }
    [self centerScrollViewContents];
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
