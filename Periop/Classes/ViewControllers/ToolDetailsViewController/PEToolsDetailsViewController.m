//
//  PEToolsDetailsViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSInteger const TDVCAnimationDuration = 0.2f;

#import "PEToolsDetailsViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEAddNewToolViewController.h"
#import "PEMediaSelect.h"
#import "PEAlbumViewController.h"
#import "PESpecialisationManager.h"
#import "EquipmentsTool.h"
#import "PECoreDataManager.h"
#import "Photo.h"


@interface PEToolsDetailsViewController () <UITextFieldDelegate, UITextInputTraits>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *specificationTextField;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextField;
@property (weak, nonatomic) IBOutlet UIImageView *equipmentPhoto;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) UIBarButtonItem * rightBarButton;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (assign, nonatomic) CGRect keyboardRect;

@end

@implementation PEToolsDetailsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"%@",((EquipmentsTool*)self.specManager.currentEquipment).name]];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure*)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    [stringForLabelTop addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0, stringForLabelTop.length)];
    self.navigationBarLabel.attributedText = stringForLabelTop;
    
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    editButton.image = [UIImage imageNamed:@"Edit"];
    self.rightBarButton = editButton;

    self.navigationItem.rightBarButtonItem=editButton;
    
    [self setSelectedObjectToView];
    
    self.nameTextField.delegate = self;
    self.specificationTextField.delegate = self;
    self.quantityTextField.delegate = self;
    self.quantityTextField.keyboardType = UIKeyboardTypeNumberPad;

}

//- (CGFloat) getWidthOfUiBarButton: (UIBarButtonItem *)button
//{
//    UIView *view = [button valueForKey:@"view"];
//    CGRect barButtonFrame;
//    if (view) {
//        barButtonFrame = [view frame];
//    } else {
//        barButtonFrame = CGRectZero;
//    }
//    return barButtonFrame.size.width;
//}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([[self.specManager.currentEquipment.photo allObjects] count]> 0) {
        if (((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoName.length>0) {
            self.equipmentPhoto.image = [UIImage imageNamed:((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoName];
        } else if (((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoData!=nil ) {
            self.equipmentPhoto.image = [UIImage imageWithData:((Photo*)[self.specManager.currentEquipment.photo allObjects][0]).photoData];
        }
    }
    
    [[self.view viewWithTag:35] removeFromSuperview];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)editButton:(id)sender
{
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
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
    
    ((EquipmentsTool*)self.specManager.currentEquipment).name = self.nameTextField.text;
    ((EquipmentsTool*)self.specManager.currentEquipment).category = self.specificationTextField.text;
    ((EquipmentsTool*)self.specManager.currentEquipment).quantity = self.quantityTextField.text;
    ((EquipmentsTool*)self.specManager.currentEquipment).createdDate = [NSDate date];
                                                                      
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]){
        NSLog(@"Cant save modified Equipment due to %@", saveError.localizedDescription);
    }
}

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.equipmentPhoto.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
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
    NSLog(@"camera Photo from Op");
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
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
        self.view.transform = CGAffineTransformMakeTranslation(0, -self.keyboardRect.size.height+self.quantityTextField.frame.size.height);
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
