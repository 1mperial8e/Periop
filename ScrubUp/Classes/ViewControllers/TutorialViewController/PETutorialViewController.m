//
//  TLViewController.m
//  Trill
//
//  Created by Anatoliy Dalekorey on 6/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PETutorialViewController.h"
#import "PETutorialCollectionViewCell.h"
#import "UIImage+ImageWithJPGFile.h"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )

static NSString *const TVCCellName = @"TutorialCell";
NSString *const TVCShowTutorial = @"ShowTutorial";
NSInteger const TVCCountPage = 5;

@interface PETutorialViewController () <UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout, PETutorialCollectionViewCellDelegate>

@property (strong, nonatomic) NSMutableArray *pageImages;

@property (weak, nonatomic) IBOutlet UICollectionView *spleshCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *spleshPageControl;

@end

@implementation PETutorialViewController

#pragma mark - Life Cycle

- (void)viewDidLoad
{
    [self createImagesArray];
    
    [self.spleshCollectionView registerNib:[UINib nibWithNibName:@"PETutorialCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"TutorialCell"];
}

#pragma mark - Private

- (void)createImagesArray
{
    self.pageImages = [[NSMutableArray alloc] init];
    for (int index = 0; index < TVCCountPage; index++) {
        NSString *imageName = IS_IPHONE_5 ? [NSString stringWithFormat:@"Screen%d-iphone5", index] : [NSString stringWithFormat:@"Screen%d-iphone4", index];
        [self.pageImages addObject:imageName];
    }
}

- (void)configureButtonInCell:(PETutorialCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == TVCCountPage - 1) {
        cell.getStartedButton.hidden = NO;
        cell.getStartedButton.layer.borderColor = [UIColor whiteColor].CGColor;
        cell.getStartedButton.layer.borderWidth = 2.0f;
        cell.getStartedButton.layer.cornerRadius = 10.0f;
        cell.getStartedButton.backgroundColor = [UIColor clearColor];
        cell.getStartedButton.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:20.0f];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    self.spleshPageControl.numberOfPages = TVCCountPage;
    return TVCCountPage;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PETutorialCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TVCCellName forIndexPath:indexPath];
    cell.tutorialImageView.image = [UIImage imageNamedFile:self.pageImages[indexPath.row]];
    [self configureButtonInCell:cell atIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}

#pragma mark - PETutorialCollectionViewCellDelegate

- (void)getStartedButtonPress
{
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:TVCShowTutorial];
    [[NSUserDefaults standardUserDefaults] synchronize];
    __weak PETutorialViewController *weakSelf = self;
    [self dismissViewControllerAnimated:NO completion:^{
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(tutorialDidFinished)]) {
            [weakSelf.delegate tutorialDidFinished];
        }
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int itemIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.spleshPageControl.currentPage = itemIndex;
}

@end
