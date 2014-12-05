//
//  PEAlbumViewController.m
//  ScrubUp
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
#import "PatientPostioning.h"
#import "Note.h"
#import "UIImage+ImageWithJPGFile.h"

static NSString *const AVCCellName = @"albumCell";

@interface PEAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@property (strong, nonatomic) NSMutableArray *selectedPhotos;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) NSInteger allowedCountOfSelectedCells;

@end

@implementation PEAlbumViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"PeAlbumCell" bundle:nil] forCellWithReuseIdentifier:AVCCellName];
    self.photosCollectionView.allowsMultipleSelection = YES;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStylePlain target:self action:@selector(choosingComplete)];
    self.navigationItem.leftBarButtonItem = closeButton;
    self.selectedPhotos = [[NSMutableArray alloc] init];
    
    self.allowedCountOfSelectedCells = [self getAllowedCountOfSelectedCells];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.photosCollectionView.contentInset = UIEdgeInsetsZero;
    self.photosCollectionView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((PENavigationController *)self.navigationController).titleLabel.text = self.navigationLabelText;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [PECameraRollManager sharedInstance].assets.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:AVCCellName forIndexPath:indexPath];
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
    
    NSInteger rewriteCounter = 0;
    
    for (UIImage *image in self.selectedPhotos) {
        NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        Photo *newPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        newPhoto.photoData = imageData;
        
        id requestedController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
        
        if ([requestedController isKindOfClass:NSClassFromString(AVCOperationRoomViewController)]) {
            NSInteger counter = [self.specManager.currentProcedure.operationRoom.photo allObjects].count;
            [self photoForOperationRoomViewController:newPhoto count:counter rewriteCount:rewriteCounter];
            if (counter == 5) {
                rewriteCounter++;
            }
        } else if ([requestedController isKindOfClass:NSClassFromString(AVCToolsDetailsViewController)]) {
            [self photoForToolsDetailsViewController:newPhoto];
        } else if ([requestedController isKindOfClass:NSClassFromString(AVCPatientPositioningViewController)]) {
            [self photoForPatientPositioningViewController:newPhoto];
        } else if ([requestedController isKindOfClass:NSClassFromString(AVCDoctorProfileViewController)]) {
            [self photoForDoctorsProfileViewController:newPhoto];
        } else if ([requestedController isKindOfClass:NSClassFromString(AVCAddEditDoctorViewController)]) {
            newPhoto.photoNumber = @0;
            self.specManager.photoObject = newPhoto;
        } else if ([requestedController isKindOfClass:NSClassFromString(AVCAddEditNoteViewController)]) {
            [self photoForNotesViewController:newPhoto];
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)getAllowedCountOfSelectedCells
{
    NSInteger allowedPhotoQuantity;
    
    id viewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];    
    if ([viewController isKindOfClass:NSClassFromString(AVCOperationRoomViewController)] ) {
        NSInteger photoCount = [self.specManager.currentProcedure.operationRoom.photo allObjects].count;
        allowedPhotoQuantity = AVCOperationRoomQuantity - photoCount;
        if (allowedPhotoQuantity < 0) {
            allowedPhotoQuantity = AVCOneQuantity;
            [self showCantAddPhotoNotification:(AVCOperationRoomQuantity + 1)];
        }
    } else if ([viewController isKindOfClass:NSClassFromString(AVCToolsDetailsViewController)]) {
        NSInteger photoCount =  [self.specManager.currentEquipment.photo allObjects].count;
        if (photoCount) {
            [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
        }
        allowedPhotoQuantity = AVCOneQuantity;
    } else if ([viewController isKindOfClass:NSClassFromString(AVCDoctorProfileViewController)]) {
        if (self.specManager.currentDoctor.photo) {
            [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
        }
        allowedPhotoQuantity = AVCOneQuantity;
    } else if([viewController isKindOfClass:NSClassFromString(AVCAddEditDoctorViewController)]) {
        if (self.specManager.currentDoctor) {
            if (self.specManager.currentDoctor.photo) {
                [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
            }
        }
        allowedPhotoQuantity = AVCOneQuantity;
    } else if ([viewController isKindOfClass:NSClassFromString(AVCPatientPositioningViewController)]){
        NSInteger photoCount = [self.specManager.currentProcedure.patientPostioning.photo allObjects].count;
        allowedPhotoQuantity = AVCOperationRoomQuantity - photoCount;
        if (allowedPhotoQuantity < 0) {
            allowedPhotoQuantity = AVCOneQuantity;
            [self showCantAddPhotoNotification:(AVCOperationRoomQuantity + 1)];
        }
    } else {
        allowedPhotoQuantity = AVCDefaultQuantity;
    }
    //
    return allowedPhotoQuantity;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self.navigationController popViewControllerAnimated:YES];
            break;
        }
    }
}

#pragma mark - Private

- (void)showCantAddPhotoNotification:(NSInteger)allowedItemsCount
{
    NSString *message = [NSString stringWithFormat:@"You can add up to %i photos. Please delete some and try again.", (int)allowedItemsCount];
    [[[UIAlertView alloc] initWithTitle:@"Can't add photos" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (BOOL)checkIfPhotoExist:(NSArray *)photoArray compareWithPhoto:(Photo *)newPhoto
{
    BOOL isAdded = NO;
    for (Photo *existingPhoto in photoArray) {
        if ([newPhoto.photoData isEqualToData:existingPhoto.photoData])
        {
            isAdded = YES;
            [self.managedObjectContext deleteObject:newPhoto];

            [[PECoreDataManager sharedManager] save];
        }
    }
    return isAdded;
}

- (void)photoForNotesViewController:(Photo *)newPhoto
{
    if (self.specManager.currentNote) {
        if (![self checkIfPhotoExist:[self.specManager.currentNote.photo allObjects] compareWithPhoto:newPhoto]) {
            newPhoto.photoNumber = @([self.specManager.currentNote.photo allObjects].count+1);
            if (!self.specManager.photoObjectsToSave) {
                self.specManager.photoObjectsToSave = [[NSMutableArray alloc] init];
            }
            [self.specManager.photoObjectsToSave addObject:newPhoto];
        }
    } else {
        if (![self checkIfPhotoExist:self.specManager.photoObjectsToSave compareWithPhoto:newPhoto]) {
            newPhoto.photoNumber = @([self.specManager.currentNote.photo allObjects].count+1);
            if (!self.specManager.photoObjectsToSave) {
                self.specManager.photoObjectsToSave = [[NSMutableArray alloc] init];
            }
            [self.specManager.photoObjectsToSave addObject:newPhoto];
        }
    }
}

- (void)photoForOperationRoomViewController:(Photo *)newPhoto count:(NSInteger)counter rewriteCount:(NSInteger)rewriteCounter
{
    if (![self checkIfPhotoExist:[self.specManager.currentProcedure.operationRoom.photo allObjects] compareWithPhoto:newPhoto]) {
        if ([self.specManager.currentProcedure.operationRoom.photo allObjects].count < 5) {
            newPhoto.operationRoom = self.specManager.currentProcedure.operationRoom;
            newPhoto.photoNumber = @(counter++);
            [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhoto];
        } else {
            [self.managedObjectContext deleteObject:self.sortedArrayWithCurrentPhoto[rewriteCounter]];
            newPhoto.photoNumber = @(rewriteCounter);
            newPhoto.operationRoom = self.specManager.currentProcedure.operationRoom;
            [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhoto];
        }

        [[PECoreDataManager sharedManager] save];
    }
}

- (void)photoForToolsDetailsViewController:(Photo *)newPhoto{
    if (![self checkIfPhotoExist:[self.specManager.currentEquipment.photo allObjects] compareWithPhoto:newPhoto]) {
        if ([self.specManager.currentEquipment.photo allObjects].count) {
            [self.managedObjectContext deleteObject:[self.specManager.currentEquipment.photo allObjects][0]];
        }
        newPhoto.equiomentTool = self.specManager.currentEquipment;
        newPhoto.photoNumber=@(0);
        [self.specManager.currentEquipment addPhotoObject:newPhoto];

        [[PECoreDataManager sharedManager] save];
    }
}

- (void)photoForPatientPositioningViewController:(Photo *)newPhoto
{
    if (![self checkIfPhotoExist:[self.specManager.currentProcedure.patientPostioning.photo allObjects] compareWithPhoto:newPhoto]) {
        newPhoto.patientPositioning = self.specManager.currentProcedure.patientPostioning;
        newPhoto.photoNumber=@([self.specManager.currentProcedure.patientPostioning.photo allObjects].count+1);
        [self.specManager.currentProcedure.patientPostioning addPhotoObject:newPhoto];

        [[PECoreDataManager sharedManager] save];
    }
}

- (void)photoForDoctorsProfileViewController:(Photo *)newPhoto
{
    if (![self.specManager.currentDoctor.photo.photoData isEqualToData:newPhoto.photoData]) {
        if (self.specManager.currentDoctor.photo) {
            [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
        }
        newPhoto.doctor = self.specManager.currentDoctor;
        newPhoto.photoNumber = @0;
        self.specManager.currentDoctor.photo = newPhoto;

        [[PECoreDataManager sharedManager] save];
    }
}

@end
