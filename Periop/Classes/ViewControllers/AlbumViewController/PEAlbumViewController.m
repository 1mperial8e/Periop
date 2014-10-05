//
//  PEAlbumViewController.m
//  Periop
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//
static NSString *const AVCCellName = @"albumCell";

static NSString *const AVCOperationRoomViewController = @"PEOperationRoomViewController";
static NSString *const AVCToolsDetailsViewController = @"PEToolsDetailsViewController";
static NSString *const AVCPatientPositioningViewController = @"PEPatientPositioningViewController";
static NSString *const AVCDoctorProfileViewController = @"PEDoctorProfileViewController";
static NSString *const AVCAddEditDoctorViewController = @"PEAddEditDoctorViewController";
static NSString *const AVCAddEditNoteViewController = @"PEAddEditNoteViewController";

static NSInteger const AVCOperationRoomQuantity = 4;
static NSInteger const AVCOneQuantity = 0;
static NSInteger const AVCDefaultQuantity = 29;


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

@interface PEAlbumViewController () <UICollectionViewDataSource, UICollectionViewDelegate>

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
    
    NSInteger counter = [self.specManager.currentProcedure.operationRoom.photo allObjects].count;
    NSInteger rewriteCounter = 0;
    
    for (UIImage *image in self.selectedPhotos) {
        NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        Photo *newPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
        newPhoto.photoData = imageData;
        
        id requestedController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
        
        if ([requestedController isKindOfClass:NSClassFromString(AVCOperationRoomViewController)]) {
            [self photoForOperationRoomViewController:newPhoto count:counter rewriteCount:rewriteCounter];
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
            newPhoto.photoNumber = @0;
            self.specManager.photoObject = newPhoto;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)getAllowedCountOfSelectedCells
{
    NSInteger allowedPhotoQuantity;
    
    id viewController = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
    if ([viewController isKindOfClass:NSClassFromString(AVCOperationRoomViewController)]) {
        allowedPhotoQuantity = AVCOperationRoomQuantity;
    } else if([viewController isKindOfClass:NSClassFromString(AVCAddEditDoctorViewController)] ||
              [viewController isKindOfClass:NSClassFromString(AVCDoctorProfileViewController)] ||
              [viewController isKindOfClass:NSClassFromString(AVCAddEditNoteViewController)] ||
              [viewController isKindOfClass:NSClassFromString(AVCToolsDetailsViewController)]) {
        allowedPhotoQuantity = AVCOneQuantity;
    } else {
        allowedPhotoQuantity = AVCDefaultQuantity;
    }
    
    return allowedPhotoQuantity;
}

#pragma mark - Private

- (void)photoForOperationRoomViewController:(Photo *)newPhoto count:(NSInteger)counter rewriteCount:(NSInteger)rewriteCounter
{
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
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant save chnages with photos operationRoom DB - %@", error.localizedDescription);
    }
}

- (void)photoForToolsDetailsViewController:(Photo *)newPhoto
{
    if ([self.specManager.currentEquipment.photo allObjects].count>0) {
        [self.managedObjectContext deleteObject:[self.specManager.currentEquipment.photo allObjects][0]];
    }
    newPhoto.equiomentTool = self.specManager.currentEquipment;
    newPhoto.photoNumber = @0;
    [self.specManager.currentEquipment addPhotoObject:newPhoto];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant save chnages with photos toolsDetails DB - %@", error.localizedDescription);
    }
}

- (void)photoForPatientPositioningViewController:(Photo *)newPhoto
{
    newPhoto.patientPositioning = self.specManager.currentProcedure.patientPostioning;
    newPhoto.photoNumber=@([self.specManager.currentProcedure.patientPostioning.photo allObjects].count+1);
    [self.specManager.currentProcedure.patientPostioning addPhotoObject:newPhoto];
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant save chnages with photos patientPostioning DB - %@", error.localizedDescription);
    }
}

- (void)photoForDoctorsProfileViewController:(Photo *)newPhoto
{
    if (self.specManager.currentDoctor.photo) {
        [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
    }
    newPhoto.doctor = self.specManager.currentDoctor;
    newPhoto.photoNumber = @0;
    self.specManager.currentDoctor.photo = newPhoto;
    NSError *error = nil;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant save chnages with photos doctorsProfile DB - %@", error.localizedDescription);
    }
}

@end
