//
//  PEAlbumViewController.m
//  Periop
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAlbumViewController.h"
#import "PECameraRollManager.h"
#import "PEAlbumCell.h"

@interface PEAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@property (strong , nonatomic) NSMutableArray *selectedPhotos;

@end

@implementation PEAlbumViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"PeAlbumCell" bundle:nil] forCellWithReuseIdentifier:@"albumCell"];
    self.photosCollectionView.allowsMultipleSelection = YES;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(choosingComplete)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    // add title label
    
    self.selectedPhotos = [[NSMutableArray alloc] init];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [PECameraRollManager sharedInstance].assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"albumCell" forIndexPath:indexPath];
    ALAsset *asset = [PECameraRollManager sharedInstance].assets[indexPath.row];
    cell.photoThumbnail.image = [UIImage imageWithCGImage:asset.thumbnail];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return !(collectionView.indexPathsForSelectedItems.count > 9);
}

#pragma mark - Private

- (void)choosingComplete
{
    for (NSIndexPath *idxPath in self.photosCollectionView.indexPathsForSelectedItems) {
        ALAsset *asset = [PECameraRollManager sharedInstance].assets[idxPath.row];
        [self.selectedPhotos addObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
    }
    // selected photos contains UIImage objects of all photos that was selected
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
