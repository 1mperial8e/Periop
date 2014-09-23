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

@interface PEAddNewToolViewController () <UITextInputTraits>

@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UITextField *specTextBox;
@property (weak, nonatomic) IBOutlet UITextField *qtyTextBox;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSArray * categoryTools;

@end

@implementation PEAddNewToolViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
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
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.qtyTextBox.keyboardType = UIKeyboardTypeNumberPad;
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
#warning to change after adding comboBox
        newEquipment.category = @"!New Category";
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

- (IBAction)cancelButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private 

- (NSArray*)getArrayWithAvaliableCategories : (NSArray* )objectsArray
{
    NSCountedSet * toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    return [toolsWithCounts allObjects];
}

@end
