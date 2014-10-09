//
//  PEToolsDetailsViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSInteger const TDVCAnimationDuration = 0.2f;
static NSInteger const TDVCViewTag = 35;
static NSString *const TDVPlaceHolderImageName = @"Place_Holder";

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


@interface PEToolsDetailsViewController () <UITextFieldDelegate, UITextInputTraits>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *specificationTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UIImageView *equipmentPhoto;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UILabel *labelSpec;
@property (weak, nonatomic) IBOutlet UILabel *labelQuantity;

@property (strong, nonatomic) UIBarButtonItem *rightBarButton;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (assign, nonatomic) CGRect keyboardRect;

@end

@implementation PEToolsDetailsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.labelName.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.labelSpec.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.labelQuantity.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    
    self.nameTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    self.specificationTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    self.quantityTextField.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;

    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    editButton.image = [UIImage imageNamedFile:@"Edit"];
    self.rightBarButton = editButton;
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;

    self.navigationItem.rightBarButtonItem=editButton;
    
    [self setSelectedObjectToView];
    
    self.nameTextField.delegate = self;
    self.specificationTextField.delegate = self;
    self.quantityTextField.delegate = self;
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPicture:)];
    [self.equipmentPhoto addGestureRecognizer:tap];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@",((EquipmentsTool *)self.specManager.currentEquipment).name]];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure *)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    [stringForLabelTop addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, stringForLabelTop.length)];
    
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    if ([[self.specManager.currentEquipment.photo allObjects] count]) {
        if (((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoName.length) {
            self.equipmentPhoto.image = [UIImage imageNamedFile:((Photo *)[self.specManager.currentEquipment.photo allObjects][0]).photoName];
        } else if (((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoData!=nil ) {
            self.equipmentPhoto.image = [UIImage imageWithData:((Photo *)[self.specManager.currentEquipment.photo allObjects][0]).photoData];
        }
    } else {
        self.equipmentPhoto.image = [UIImage imageNamedFile:TDVPlaceHolderImageName];
    }
    
    [(PEMediaSelect *)[self.view viewWithTag:TDVCViewTag] setVisible:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)editButton:(id)sender
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    self.nameTextField.enabled = true;
    self.specificationTextField.enabled = true;
    self.quantityTextField.enabled = true;
}

- (IBAction)saveButton:(id)sender
{
    self.navigationItem.rightBarButtonItem = self.rightBarButton;
    self.nameTextField.enabled = false;
    self.specificationTextField.enabled = false;
    self.quantityTextField.enabled = false;
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {
        [self.view endEditing:YES];
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    
    ((EquipmentsTool *)self.specManager.currentEquipment).name = self.nameTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).category = self.specificationTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).quantity = self.quantityTextField.text;
    ((EquipmentsTool *)self.specManager.currentEquipment).createdDate = [NSDate date];
                                                                      
    NSError *saveError;
    if (![self.managedObjectContext save:&saveError]){
        NSLog(@"Cant save modified Equipment due to %@", saveError.localizedDescription);
    }
}

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.equipmentPhoto.frame;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = array[0];
    view.frame = position;
    view.tag = TDVCViewTag;
    [self.view addSubview:view];
    [view setVisible:YES];
}

- (void)tapOnPicture:(UITapGestureRecognizer *)gesture
{
    if ([[self.specManager.currentEquipment.photo allObjects] count] && [((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoData hash]!= [[UIImage imageNamedFile:TDVPlaceHolderImageName] hash]) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
            if ([[self.specManager.currentEquipment.photo allObjects] count]) {
                viewPhotoControleller.photoToShow = (Photo *)[self.specManager.currentEquipment.photo allObjects][0];
            }
            [self.navigationController pushViewController:viewPhotoControleller animated:YES];
        }
    }
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
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
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {
        [textField resignFirstResponder];
        self.view.transform = CGAffineTransformMakeTranslation(0, 0);
    }];
    
    return YES;
}

#pragma mark - Notifcation

- (void)keyboardWillChange:(NSNotification *)notification
{
    self.keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.keyboardRect = [self.view convertRect:self.keyboardRect fromView:nil];
    
    [UIView animateWithDuration:TDVCAnimationDuration animations:^ {
        self.view.transform = CGAffineTransformMakeTranslation(0, -self.keyboardRect.size.height);
    }];
}

#pragma mark - Private

- (void)setSelectedObjectToView
{
    self.nameTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).name;
    self.specificationTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).category;
    self.quantityTextField.text = ((EquipmentsTool*)self.specManager.currentEquipment).quantity;
}

@end
