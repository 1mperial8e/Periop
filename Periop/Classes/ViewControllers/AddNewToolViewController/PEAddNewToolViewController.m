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

@interface PEAddNewToolViewController () <UITextInputTraits, UIDropDownListDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UITextField *specTextBox;
@property (weak, nonatomic) IBOutlet UITextField *qtyTextBox;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *specLabel;
@property (weak, nonatomic) IBOutlet UILabel *qtyLabel;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSArray * categoryTools;
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
    
    self.nameLabel.font = [UIFont fontWithName:@"MuseoSans_700" size:17.5f];
    self.specLabel.font = [UIFont fontWithName:@"MuseoSans_700" size:17.5f];
    self.qtyLabel.font = [UIFont fontWithName:@"MuseoSans_700" size:17.5f];
    self.nameTextBox.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0f];
    self.specTextBox.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0f];
    self.qtyTextBox.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0f];
    
    
    self.categoryTools = [self getArrayWithAvaliableCategories:[self.specManager.currentProcedure.equipments allObjects]];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.text =((EquipmentsTool*)self.specManager.currentProcedure).name;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.numberOfLines = 0;
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.qtyTextBox.keyboardType = UIKeyboardTypeNumberPad;
    
    [self createDropDownList];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)saveButton:(id)sender
{
    if (self.nameTextBox.text || self.qtyTextBox.text || self.specTextBox.text) {
        NSEntityDescription * equipmentEntity = [NSEntityDescription entityForName:@"EquipmentsTool" inManagedObjectContext:self.managedObjectContext];
        EquipmentsTool * newEquipment = [[EquipmentsTool alloc] initWithEntity:equipmentEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newEquipment.name = self.nameTextBox.text;
        newEquipment.quantity = self.qtyTextBox.text;
        newEquipment.type = self.specTextBox.text;
        newEquipment.createdDate = [NSDate date];
        if ([self.dropDownList.titleLabel.text isEqualToString:@"Equipment Category"]) {
            UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"Category not selected" message:@"Please select category for new equipment" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
        } else {
            newEquipment.category = self.dropDownList.titleLabel.text;
            [self.specManager.currentProcedure addEquipmentsObject:newEquipment];
            NSError * saveError = nil;
            if (![self.managedObjectContext save:&saveError]) {
                NSLog(@"Cant save new tool - %@", saveError.localizedDescription);
            } else {
                NSLog(@"New tool \"%@\" added successfully", newEquipment.name);
            }
            self.nameTextBox.text=@"";
            self.qtyTextBox.text =@"";
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

#pragma mark - UIDropDownListDelegate

- (void)dropDownList:(UIDropDownList *)dropDownList didSelectItemAtIndex:(NSInteger)idx
{
    
}

- (void)dropDownList:(UIDropDownList *)dropDownList willOpenWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds
{
    if (animation) {
        [UIView animateWithDuration:animation.duration animations:^{
            self.dropDownListHeight.constant = bounds.size.height;
            [self.view layoutIfNeeded];
        }];
    }
}

- (void)dropDownList:(UIDropDownList *)dropDownList willCloseWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds
{
    if (animation) {
        [UIView animateWithDuration:animation.duration animations:^{
            self.dropDownListHeight.constant = bounds.size.height;
            [self.view layoutIfNeeded];
        }];
    }
}

#pragma mark - Private 

- (NSArray*)getArrayWithAvaliableCategories : (NSArray* )objectsArray
{
    NSCountedSet * toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    return [toolsWithCounts allObjects];
}

- (void)createDropDownList
{
    self.dropDownList = [[UIDropDownList alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40.0)];
    self.dropDownList.items = @[@"Disposables", @"Drapes", @"Dressing", @"Equipment", @"Extra Instruments/Equipment", @"Gloves", @"Holloware", @"Instrument Tray",  @"Prep Solution", @"Prosthesis", @"Solutions", @"Sutures"];
    [self.dropDownList setBackgroundColor:[UIColor colorWithRed:(147.0/255.0) green:(227.0/255.0) blue:(185.0/255.0) alpha:1.0f]];
    self.dropDownList.titleLabel.textColor = [UIColor whiteColor];
    self.dropDownList.separateColor = [UIColor colorWithRed:(245.0/255.0) green:(245.0/255.0) blue:(245.0/255.0) alpha:1.0f];
    self.dropDownList.titleLabel.text = @"Equipment Category";
    self.dropDownList.titleLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(0, self.dropDownList.frame.size.height - 1, self.dropDownList.frame.size.width, 0.5f)];
    separator.backgroundColor = [UIColor whiteColor];
    [self.dropDownList addSubview:separator];
    self.dropDownList.numberOfItemsToDraw = 4;
    self.dropDownList.itemBackColor = [UIColor whiteColor];
    self.dropDownList.itemLabelTextColor = [UIColor colorWithRed:(28.0/255.0) green:(28.0/255.0) blue:(28.0/255.0) alpha:1.0f];
    self.dropDownList.itemLabelFont = [UIFont fontWithName:@"MuseoSans-300" size:15.0];
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
