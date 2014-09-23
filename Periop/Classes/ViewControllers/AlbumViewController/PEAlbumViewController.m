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
#import "PESpecialisationManager.h"
#import "PEOperationRoomViewController.h"
#import "PECoreDataManager.h"
#import "Photo.h"

@interface PEAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) UILabel * navigationLabel;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (assign, nonatomic) NSInteger allowedCountOfSelectedCells;

@end

@implementation PEAlbumViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"PeAlbumCell" bundle:nil] forCellWithReuseIdentifier:@"albumCell"];
    self.photosCollectionView.allowsMultipleSelection = YES;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(choosingComplete)];
    self.navigationItem.leftBarButtonItem = closeButton;
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationLabel.textColor = [UIColor whiteColor];
    self.navigationLabel.minimumScaleFactor = 0.5;
    self.navigationLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationLabel.text = self.navigationLabelText;
    self.selectedPhotos = [[NSMutableArray alloc] init];
    
    self.allowedCountOfSelectedCells = [self getAllowedCountOfSelectedCells];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationLabel removeFromSuperview];
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
    return !(collectionView.indexPathsForSelectedItems.count > self.allowedCountOfSelectedCells);
}

#pragma mark - Private

- (void)choosingComplete
{
    for (NSIndexPath *idxPath in self.photosCollectionView.indexPathsForSelectedItems) {
        ALAsset *asset = [PECameraRollManager sharedInstance].assets[idxPath.row];
        [self.selectedPhotos addObject:[UIImage imageWithCGImage:asset.defaultRepresentation.fullScreenImage]];
    }
    
    NSInteger counter = [self.specManager.currentProcedure.operationRoom.photo allObjects].count;
    NSInteger rewriteCounter = 0;
    
    for (UIImage * image in self.selectedPhotos) {
        NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        Photo * newPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSData * imageData = UIImageJPEGRepresentation(image, 1.0);
        newPhoto.photoData = imageData;
        
        if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEOperationRoomViewController"]) {
            if ([self.specManager.currentProcedure.operationRoom.photo allObjects].count<5) {
                newPhoto.operationRoom = self.specManager.currentProcedure.operationRoom;
                newPhoto.photoNumber = @(counter++);
                [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhoto];
            } else {
                [self.managedObjectContext deleteObject:self.sortedArrayWithCurrentPhoto[rewriteCounter]];
                newPhoto.photoNumber = @(rewriteCounter);
                newPhoto.operationRoom = self.specManager.currentProcedure.operationRoom;
                [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhoto];
                rewriteCounter++;
            }
        }
#warning to implement save photo for others controllers
        
    }
    NSError * error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant save photo ot DB - %@", error.localizedDescription);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)getAllowedCountOfSelectedCells
{
    if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEOperationRoomViewController"]) {
        return  4;
    } else {
        return 30;
    }
}

@end
