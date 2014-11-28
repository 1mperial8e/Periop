//
//  PEToolsDetailsViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEToolsDetailsViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEAddNewToolViewController.h"
#import "PEMediaSelect.h"
#import "PEAlbumViewController.h"
#import "PESpecialisationManager.h"
#import "EquipmentsTool.h"
#import "PECoreDataManager.h"
#import "Photo.h"
#import "PEViewPhotoViewController.h"
#import "PECameraViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PEBlurEffect.h"
#import "PELabelConfiguration.h"

static NSString *const TDVCellNibName = @"PEOperationRoomCollectionViewCell";
static NSString *const TDVCellIdentifier = @"OperationRoomViewCell";
static NSString *const TDVPlaceHolderImageName = @"Place_Holder";
static NSInteger const TDVCAnimationDuration = 0.2f;
static NSInteger const TDVCViewTag = 35;

@interface PEToolsDetailsViewController () <UITextFieldDelegate, UITextInputTraits, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *specificationTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSpec;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (strong, nonatomic) UIBarButtonItem *rightBarButtonEdit;
@property (strong, nonatomic) UIBarButtonItem *rightBarButtonSave;
@property (assign, nonatomic) BOOL isEdit;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic)NSMutableArray *sortedArrayWithPhotos;

@end

@implementation PEToolsDetailsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.labelName.font = [UIFont fontWithName:FONT_MuseoSans700 size:20.0f];
    self.labelSpec.font = [UIFont fontWithName:FONT_MuseoSans700 size:20.0f];
    self.labelQuantity.font = [UIFont fontWithName:FONT_MuseoSans700 size:20.0f];
    
    self.nameTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:17.5f];
    self.specificationTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:17.5f];
    self.quantityTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:17.5f];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.edgesForExtendedLayout = UIRectEdgeAll;

    [self configureNavigationItems];
    [self setSelectedObjectToView];
    
    [self.collectionView registerNib:[UINib nibWithNibName:TDVCellNibName bundle:nil] forCellWithReuseIdentifier:TDVCellIdentifier];
    
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.specificationTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.quantityTextField.autocapitalizationType = UITextAutocapitalizationTypeSentences;
    
    self.nameTextField.delegate = self;
    self.specificationTextField.delegate = self;
    self.quantityTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.isEdit) {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonSave;
    } else {
        self.navigationItem.rightBarButtonItem = self.rightBarButtonEdit;
    }
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@",((EquipmentsTool *)self.specManager.currentEquipment).name]];
    
    [stringForLabelTop addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:20.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure *)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:13.5] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    [stringForLabelTop addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, stringForLabelTop.length)];
    
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentEquipment.photo allObjects]];
    
    [(PEMediaSelect *)[self.view viewWithTag:TDVCViewTag] setVisible:NO];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    self.sortedArrayWithPhotos = nil;
    self.navigationItem.rightBarButtonItem = nil;
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.scrollView.contentInset = UIEdgeInsetsZero;
    self.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)editButton:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.rightBarButtonSave;
    self.nameTextField.enabled = true;
    self.specificationTextField.enabled = true;
    self.quantityTextField.enabled = true;
    self.isEdit = !self.isEdit;
}

- (IBAction)saveButton:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.rightBarButtonEdit;
    self.nameTextField.enabled = false;
    self.specificationTextField.enabled = false;
    self.quantityTextField.enabled = false;
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {
        [self.view endEditing:YES];
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    ((EquipmentsTool *)self.specManager.currentEquipment).name = self.nameTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).type = self.specificationTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).quantity = self.quantityTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).createdDate = [NSDate date];
                                                                      
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]){
        NSLog(@"Cant save modified Equipment due to %@", saveError.localizedDescription);
    }
    self.isEdit = !self.isEdit;
}

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.collectionView.frame;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = array[0];
    view.frame = position;
    view.tag = TDVCViewTag;
    
    [view addSubview:[PELabelConfiguration setInformationLabelOnView:view]];
    
    [self.view addSubview:view];
    [view setVisible:YES];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
    albumViewController.sortedArrayWithCurrentPhoto = self.sortedArrayWithPhotos;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = EquipmentsToolViewController;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [(PEMediaSelect *)[self.view viewWithTag:TDVCViewTag] setVisible:NO];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {        
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    
    return YES;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.sortedArrayWithPhotos.count) {
        return self.sortedArrayWithPhotos.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEOperationRoomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TDVCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEOperationRoomCollectionViewCell alloc] init];
    }
    if (self.sortedArrayWithPhotos.count) {
        if (((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoData) {
        UIImage *image = [UIImage imageWithData:((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoData];
        cell.operationRoomImage.image = image;
        } else if (((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoName) {
            [self asyncDownloadImageForCell:cell atIndexPath:indexPath];
        }
    } else {
        cell.operationRoomImage.image = [UIImage imageNamedFile:TDVPlaceHolderImageName];
    }
    cell.operationRoomImage.frame = cell.bounds;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (((Photo *)[self.specManager.currentEquipment.photo allObjects][0]).photoData) {
        self.navigationController.navigationBar.translucent = YES;
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        if ([[self.specManager.currentEquipment.photo allObjects] count]) {
            viewPhotoControleller.photoToShow = self.sortedArrayWithPhotos[indexPath.row];
        }
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

#pragma mark - Notifcation

- (void)keyboardWillChange:(NSNotification *)notification
{
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {
        self.view.transform = CGAffineTransformMakeTranslation(0, -keyboardRect.size.height);
    }];
}

#pragma mark - Private

- (void)asyncDownloadImageForCell:(PEOperationRoomCollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    dispatch_queue_t myQueue = dispatch_queue_create("imageDownloadingQueue", NULL);
    dispatch_async(myQueue, ^{
        NSURL *urlForImage = [NSURL URLWithString:((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoName];
        NSData *imageDataFromUrl = [NSData dataWithContentsOfURL:urlForImage];
        
        NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
        Photo *initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
        initPhoto.photoData = imageDataFromUrl;
        initPhoto.photoName = ((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoName;
        initPhoto.equiomentTool = self.specManager.currentEquipment;
        
        [self.specManager.currentEquipment removePhotoObject:self.sortedArrayWithPhotos[indexPath.row]];
        [self.specManager.currentEquipment addPhotoObject:initPhoto];
        NSError *error;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Error - %@", error.localizedDescription);
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.operationRoomImage.image = [UIImage imageWithData:imageDataFromUrl];;
            NSLog(@"Image downloaded and saved to DB");
        });
    });
}

- (void)configureNavigationItems
{
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    editButton.image = [UIImage imageNamedFile:@"Edit"];
    self.rightBarButtonEdit = editButton;
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    [saveButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:FONT_MuseoSans500 size:13.5f]} forState:UIControlStateNormal];
    self.rightBarButtonSave = saveButton;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
}

- (void)setSelectedObjectToView
{
    self.nameTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).name;
    self.specificationTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).type;
    self.quantityTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).quantity;
}

- (NSMutableArray *)sortedArrayWithPhotos: (NSArray *)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *firstObject = ((Photo*)obj1).photoNumber;
        NSNumber *secondObject = ((Photo*)obj2).photoNumber;
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

@end
