//
//  PEAddNewToolViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddNewToolViewController.h"
#import "PESpecialisationManager.h"
#import "EquipmentsTool.h"
#import "PECoreDataManager.h"
#import "Procedure.h"
#import "UIDropDownList.h"
#import "UIImage+ImageWithJPGFile.h"

static NSString *const ANTDefaultEquipmentStr = @"Equipment Category";
static NSString *const ANTEquipmentEntityName = @"EquipmentsTool";

@interface PEAddNewToolViewController () <UITextInputTraits, UITextFieldDelegate, UIDropDownListDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UITextField *specTextBox;
@property (weak, nonatomic) IBOutlet UITextField *quantityTextBox;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *specLabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *categoryTools;
@property (strong, nonatomic) UIDropDownList *dropDownList;
@property (strong, nonatomic) NSLayoutConstraint *dropDownListHeight;

@end

@implementation PEAddNewToolViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.nameLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.specLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.quantityLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    self.nameTextBox.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    self.specTextBox.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    self.quantityTextBox.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0f];
    
    self.categoryTools = [self getArrayWithAvaliableCategories:[self.specManager.currentProcedure.equipments allObjects]];
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    [saveButton setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:FONT_MuseoSans500 size:13.5]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    [self createDropDownList];
    [self initGestures];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = ((EquipmentsTool *)self.specManager.currentProcedure).name;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)saveButton:(id)sender
{
    if (self.nameTextBox.text || self.quantityTextBox.text || self.specTextBox.text) {
        NSEntityDescription *equipmentEntity = [NSEntityDescription entityForName:ANTEquipmentEntityName inManagedObjectContext:self.managedObjectContext];
        EquipmentsTool *newEquipment = [[EquipmentsTool alloc] initWithEntity:equipmentEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newEquipment.name = self.nameTextBox.text;
        newEquipment.quantity = self.quantityTextBox.text;
        newEquipment.type = self.specTextBox.text;
        newEquipment.createdDate = [NSDate date];
        if ([self.dropDownList.titleLabel.text isEqualToString:ANTDefaultEquipmentStr]) {
            [[[UIAlertView alloc] initWithTitle:@"Category not selected" message:@"Please select category for new equipment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            newEquipment.category = self.dropDownList.titleLabel.text;
            [self.specManager.currentProcedure addEquipmentsObject:newEquipment];
            NSError *saveError = nil;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"Cant save new tool - %@", saveError.localizedDescription);
            }
            self.nameTextBox.text=@"";
            self.quantityTextBox.text =@"";
            self.specTextBox.text = @"";
            [self.view endEditing:YES];

            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (IBAction)cancelButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showKeyboard:(UITapGestureRecognizer *)gesture
{
    UIView *label = gesture.view;
    if (label == self.nameLabel) {
        [self.nameTextBox becomeFirstResponder];
    } else if (label == self.specLabel) {
        [self.specTextBox becomeFirstResponder];
    } else {
        [self.quantityTextBox becomeFirstResponder];
    }
}

#pragma mark - UIDropDownListDelegate

- (void)dropDownList:(UIDropDownList *)dropDownList willOpenWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds
{
    for (UITextField *textfield in self.containerView.subviews) {
        [textfield resignFirstResponder];
    }
    if (animation) {
        PEAddNewToolViewController __weak *weakSelf = self;
        [UIView animateWithDuration:animation.duration animations:^{
            weakSelf.dropDownListHeight.constant = bounds.size.height;
            [weakSelf.view layoutIfNeeded];
        }];
    }
}

- (void)dropDownList:(UIDropDownList *)dropDownList willCloseWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds
{
    if (animation) {
        PEAddNewToolViewController __weak *weakSelf = self;
        [UIView animateWithDuration:animation.duration animations:^{
            weakSelf.dropDownListHeight.constant = bounds.size.height;
            [weakSelf.view layoutIfNeeded];
        }];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Private 

- (NSArray *)getArrayWithAvaliableCategories:(NSArray *)objectsArray
{
    NSCountedSet *toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    return [toolsWithCounts allObjects];
}

- (void)initGestures
{
    UITapGestureRecognizer *nameGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard:)];
    [self.nameLabel addGestureRecognizer:nameGesture];
    
    UITapGestureRecognizer *specGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard:)];
    [self.specLabel addGestureRecognizer:specGesture];
    
    UITapGestureRecognizer *quantityGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showKeyboard:)];
    [self.quantityLabel addGestureRecognizer:quantityGesture];
}

- (void)createDropDownList
{
    self.dropDownList = [[UIDropDownList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0)];
    self.dropDownList.items = @[@"Disposables", @"Drapes", @"Dressing", @"Equipment", @"Extra Instruments/Equipment", @"Gloves", @"Holloware", @"Instrument Tray",  @"Prep Solution", @"Prosthesis", @"Solutions", @"Sutures"];
    [self.dropDownList setBackgroundColor:UIColorFromRGB(0x93E3B9)];
    self.dropDownList.titleLabel.textColor = [UIColor whiteColor];
    self.dropDownList.separateColor = UIColorFromRGB(0xF5F5F5);
    self.dropDownList.titleLabel.text = ANTDefaultEquipmentStr;
    self.dropDownList.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.dropDownList.frame.size.height - 1, self.dropDownList.frame.size.width, 0.5f)];
    separator.backgroundColor = [UIColor whiteColor];
    [self.dropDownList addSubview:separator];
    self.dropDownList.numberOfItemsToDraw = 4;
    self.dropDownList.itemBackColor = [UIColor whiteColor];
    self.dropDownList.itemLabelTextColor = UIColorFromRGB(0x1C1C1C);
    self.dropDownList.itemLabelFont = [UIFont fontWithName:FONT_MuseoSans300 size:15.0];
    self.dropDownList.itemHeight = 30.0f;
    self.dropDownList.delegate = self;
    
    self.dropDownList.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.dropDownListHeight = [NSLayoutConstraint constraintWithItem:self.dropDownList
                                                           attribute:NSLayoutAttributeHeight
                                                           relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                              toItem:nil
                                                           attribute:NSLayoutAttributeHeight
                                                          multiplier:1.0
                                                            constant:self.dropDownList.frame.size.height];
    
    [self.dropDownList addConstraint:self.dropDownListHeight];
    
    [self.view addSubview:self.dropDownList];
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:self.dropDownList
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTop
                                                            multiplier:1.0
                                                              constant:0.0],
                                [NSLayoutConstraint constraintWithItem:self.dropDownList
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:0.0],
                                [NSLayoutConstraint constraintWithItem:self.dropDownList
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:0.0]]];
    
    UIView *container = self.containerView;
    [self.containerView removeFromSuperview];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    CGRect frame = container.frame;
    frame.origin.x = self.dropDownList.frame.size.height;
    container.frame = frame;
    [self.view addSubview:container];
    
    [self.view addConstraints:@[[NSLayoutConstraint constraintWithItem:container
                                                             attribute:NSLayoutAttributeTop
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.dropDownList
                                                             attribute:NSLayoutAttributeBottom
                                                            multiplier:1.0
                                                              constant:0.0],
                                [NSLayoutConstraint constraintWithItem:container
                                                             attribute:NSLayoutAttributeLeading
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeLeading
                                                            multiplier:1.0
                                                              constant:0.0],
                                [NSLayoutConstraint constraintWithItem:container
                                                             attribute:NSLayoutAttributeTrailing
                                                             relatedBy:NSLayoutRelationEqual
                                                                toItem:self.view
                                                             attribute:NSLayoutAttributeTrailing
                                                            multiplier:1.0
                                                              constant:0.0]]];
}

@end
