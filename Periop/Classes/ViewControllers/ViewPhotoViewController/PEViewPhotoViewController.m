//
//  PEViewPhotoViewController.m
//  Periop
//
//  Created by Kirill on 9/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEViewPhotoViewController.h"
#import "PESpecialisationManager.h"
#import "PECoreDatamanager.h"
#import "PatientPostioning.h"
#import "Note.h"
#import "PEViewPhotoViewCollectionViewCell.h"
#import "Photo.h"

static NSString *const VPVCOperationRoomViewController = @"PEOperationRoomViewController";
static NSString *const VPVCToolsDetailsViewController = @"PEToolsDetailsViewController";
static NSString *const VPVCPatientPositioningViewController = @"PEPatientPositioningViewController";
static NSString *const VPVCDoctorProfileViewController = @"PEDoctorProfileViewController";
static NSString *const VPVCAddEditDoctorViewController = @"PEAddEditDoctorViewController";
static NSString *const VPVCNotesViewController = @"PENotesViewController";

static NSString *const VPVCCellNibName = @"PEViewPhotoViewCollectionViewCell";
static NSString *const VPVCCellIdentifier = @"imageViewCell";


@interface PEViewPhotoViewController () < UINavigationControllerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionViewPhoto;

//@property (strong, nonatomic) UIImageView *imageView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) CAGradientLayer *gradient;

@property (assign, nonatomic) BOOL isFullScreen;
@property (strong, nonatomic) NSMutableArray * arrayWithPhotoToShow;
@property (strong, nonatomic) NSIndexPath *indexPathForCurrentItem;

@end

@implementation PEViewPhotoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    
    [self.collectionViewPhoto registerNib:[UINib nibWithNibName:VPVCCellNibName bundle:nil] forCellWithReuseIdentifier:VPVCCellIdentifier];
    
    [self configureDataSource];
    self.indexPathForCurrentItem = [NSIndexPath indexPathForItem:0 inSection:0];
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.viewContainer.bounds;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xF5F3FE) CGColor], (id)[UIColorFromRGB(0xC9EAFE) CGColor], nil];
    [self.viewContainer.layer insertSublayer:self.gradient atIndex:0];
    self.edgesForExtendedLayout = UIRectEdgeTop;
    self.isFullScreen = NO;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHideNavBar:)];
    [self.collectionViewPhoto addGestureRecognizer:tapGesture];
    
//    UIImage *photo;
//    if (self.photoToShow) {
//        photo = [UIImage imageWithData:self.photoToShow.photoData];
//    }
//    CGSize size = photo.size;
//    size.width = self.view.bounds.size.width;
//    size.height = size.height * (size.width / photo.size.width);
//    self.imageView = [[UIImageView alloc] initWithImage:photo];
//    self.imageView.bounds = CGRectMake(0, 0, size.width, size.height);
//    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
//    
//    [self.photoScrollView addSubview:self.imageView];
//    self.photoScrollView.contentSize = size;
    
//    [self configPhotoScrollView];
//    [self centerScrollViewContents];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    CGRect bounds = self.gradient.bounds;
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            return;
        }
        bounds.size.width = self.view.bounds.size.width + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        
//        CGSize size = CGSizeMake(self.imageView.image.size.height, self.imageView.image.size.width);
//        size.height = self.view.bounds.size.height;
//        size.width = size.width * (size.height / self.imageView.image.size.width);
//        self.imageView.bounds = CGRectMake(0, 0, size.height, size.width);
        
//        self.photoScrollView.contentSize = CGSizeMake(size.height, size.width);
    } else {
        if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
            return;
        }
        bounds.size.width = self.view.bounds.size.height + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
        
//        CGSize size = self.imageView.image.size;
//        size.height = self.view.bounds.size.width;
//        size.width = size.width * (size.height / self.imageView.image.size.height);
//        self.imageView.bounds = CGRectMake(0, 0, size.width, size.height);
        
//        self.photoScrollView.contentSize = size;
    }
//    [self centerScrollViewContents];
    self.gradient.frame = bounds;
    
    PEViewPhotoViewCollectionViewCell *cell = (PEViewPhotoViewCollectionViewCell *)[self.collectionViewPhoto cellForItemAtIndexPath:self.indexPathForCurrentItem];
    [self.collectionViewPhoto.collectionViewLayout invalidateLayout];
    CGSize size;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        size = CGSizeMake(self.view.bounds.size.height, self.view.bounds.size.width);
    } else {
        size = self.view.bounds.size;
    }
    
    [cell resizeCell:toInterfaceOrientation boundsParam:CGRectMake(0, 0, size.width, size.height)];
    
    [self.collectionViewPhoto reloadData];
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [self centerContent];
    } else if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) && UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        [self centerContent];
    }
    self.collectionViewPhoto.contentInset = UIEdgeInsetsZero;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    CGRect frame = [UIScreen mainScreen].bounds;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation)) {
            frame.size.width *= frame.size.height;
            frame.size.height = frame.size.width / frame.size.height;
            frame.size.width /= frame.size.height;
        }
    }    
    self.view.frame = frame;
    
    PEViewPhotoViewCollectionViewCell *cell = (PEViewPhotoViewCollectionViewCell *)[self.collectionViewPhoto cellForItemAtIndexPath:self.indexPathForCurrentItem];
    [cell centerScrollViewContents];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.isFullScreen) {
        self.navigationController.navigationBar.alpha = 0;
    } else {
        self.navigationController.navigationBar.alpha = 1;
    }
//    self.photoScrollView.contentInset = UIEdgeInsetsZero;
//    [self centerScrollViewContents];
//    self.photoScrollView.bounds = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"View Photo";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20];
    self.navigationItem.titleView = titleLabel;
    ((PENavigationController *)self.navigationController).titleLabel.text = @"";
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationItem.titleView removeFromSuperview];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.indexPathForCurrentItem = [[self.collectionViewPhoto indexPathsForVisibleItems] lastObject];
    
//    for (NSIndexPath *indexPath in self.collectionViewPhoto.indexPathsForVisibleItems) {
//        PEViewPhotoViewCollectionViewCell *cell = (PEViewPhotoViewCollectionViewCell *)[self.collectionViewPhoto cellForItemAtIndexPath:indexPath];
//        if (ABS(cell.frame.origin.x - self.collectionViewPhoto.contentOffset.x) <= 50) {
//            self.pageControll.currentPage = indexPath.row;
//        }
//    }
}

#pragma mark - Rotation

-(NSUInteger)supportedInterfaceOrientations
{
    return  UIInterfaceOrientationMaskAll;
}

- (void)canRotate
{
    //dummy
}

#pragma mark - IBActions

- (IBAction)removeImageButton:(id)sender
{
    if (self.photoToShow) {
        id viewController = self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2];
        
        if ([viewController isKindOfClass:NSClassFromString(VPVCOperationRoomViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.operationRoom.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.operationRoom removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCPatientPositioningViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.patientPostioning.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.patientPostioning removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCToolsDetailsViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentEquipment.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentEquipment removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCDoctorProfileViewController)]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCAddEditDoctorViewController)]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCNotesViewController)]) {
            if ([((Photo*)self.specManager.currentNote.photo).photoData isEqualToData:self.photoToShow.photoData]) {
                if (self.specManager.currentNote.photo) {
                    [self.managedObjectContext deleteObject:(Photo*)self.specManager.currentNote.photo];
                }
                self.specManager.currentNote.photo = nil;
            }
        }
        NSError* removeError;
        if (![self.managedObjectContext save:&removeError]) {
            NSLog(@"Cant remove image - %@", removeError.localizedDescription);
        }        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)showHideNavBar:(UITapGestureRecognizer *)tapGesture
{
    __weak PEViewPhotoViewController *weakSelf = self;
    if (self.isFullScreen) {
        [UIView animateWithDuration:0.32 animations:^{
            weakSelf.viewContainer.alpha = 1;
            weakSelf.navigationController.navigationBar.alpha = 1;
            weakSelf.view.backgroundColor = [UIColor whiteColor];
        }];
    } else {
        [UIView animateWithDuration:0.32 animations:^{
            weakSelf.viewContainer.alpha = 0;
            weakSelf.navigationController.navigationBar.alpha = 0;
            weakSelf.view.backgroundColor = [UIColor blackColor];
        }];
    }
    self.isFullScreen = !self.isFullScreen;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayWithPhotoToShow.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEViewPhotoViewCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:VPVCCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEViewPhotoViewCollectionViewCell alloc] init];
    }
    UIImage *myImage = [UIImage imageWithData: ((Photo *)self.arrayWithPhotoToShow[indexPath.row]).photoData];
    CGSize size = myImage.size;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        size.width = self.view.bounds.size.width;
        CGFloat koef = (self.view.bounds.size.width / myImage.size.width);
        size.height = size.height * koef;
    } else {
        size.height = self.view.bounds.size.height;
        CGFloat koef = (self.view.bounds.size.height / myImage.size.height);
        size.width = size.width * koef;
    }
    cell.backgroundColor = [UIColor colorWithRed:(80 / 255.0) green:((indexPath.row * 30) / 255.0) blue:((indexPath.row * 30) / 255.0) alpha:1];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    imageView.image = myImage;
    cell.imageViewForSelectedPhoto = imageView;
    cell.imageViewForSelectedPhoto.contentMode = UIViewContentModeScaleAspectFit;
    [cell.photoScrollView addSubview:imageView];
    cell.photoScrollView.contentSize = size;
    //cell.photoScrollView.zoomScale = 1.0f;
    cell.photoScrollView.frame = self.collectionViewPhoto.frame;
    
    [cell centerScrollViewContents];
    
    return cell;
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.collectionViewPhoto.bounds.size;
}

#pragma mark - Private

- (void)configureDataSource
{
    if (!self.arrayWithPhotoToShow) {
        self.arrayWithPhotoToShow = [[NSMutableArray alloc] init];
    }
    
    self.arrayWithPhotoToShow = [[self.specManager.currentNote.photo allObjects] mutableCopy];
}

- (void)centerContent
{
    CGSize size;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 8.0f) {
        size = CGSizeMake(self.view.bounds.size.height, self.view.bounds.size.width);
    } else {
        size = self.view.bounds.size;
    }
    CGFloat originX = size.width * self.indexPathForCurrentItem.row;
    CGSize contentSize = CGSizeMake(size.width * self.arrayWithPhotoToShow.count, size.height);
    self.collectionViewPhoto.contentSize = contentSize;
    [self.collectionViewPhoto setContentOffset:CGPointMake(originX, 0) animated:NO];
}

//- (void)configPhotoScrollView
//{
//    self.photoScrollView.minimumZoomScale = 1.0f;
//    self.photoScrollView.maximumZoomScale = 4.0f;
//    self.photoScrollView.zoomScale = 1.0;
//}
//
//- (void)centerScrollViewContents
//{
//    CGSize boundsSize = self.photoScrollView.bounds.size;
//    CGRect contentsFrame = self.imageView.frame;
//    
//    if (contentsFrame.size.width < boundsSize.width) {
//        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
//    } else {
//        contentsFrame.origin.x = 0.0f;
//    }
//    
//    if (contentsFrame.size.height < boundsSize.height) {
//        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
//    } else {
//        contentsFrame.origin.y = 0.0f;
//    }
//    
//    self.imageView.frame = contentsFrame;
//}
//
//#pragma mark - UIScrollView delegate
//
//- (void)scrollViewDidZoom:(UIScrollView *)scrollView
//{
//    [self centerScrollViewContents];
//}
//
//- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
//{
//    return self.imageView;
//}

@end
