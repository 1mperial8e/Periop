//
//  PEAddEditStepViewControllerViewController.m
//  ScrubUp
//
//  Created by Stas Volskyi on 16.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddEditStepViewControllerViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PECoreDataManager.h"
#import "PESpecialisationManager.h"
#import "Preparation.h"
#import "Steps.h"
#import "PatientPostioning.h"

static NSString *const AESStepsEntityName = @"Steps";
static NSString *const AESPreparationEntityName = @"Preparation";
static NSString *const AESOperationRoomEntityName = @"OperationRoom";
static NSString *const AESPatientPositioningEntityName = @"PatientPositioning";

@interface PEAddEditStepViewControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;
@property (weak, nonatomic) IBOutlet UITextView *stepTextView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;

@end

@implementation PEAddEditStepViewControllerViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    
    [self setupUI];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    self.specManager.currentPreparation = nil;
    self.specManager.currentStep = nil;
}

- (void)setupUI
{
    self.stepLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
    self.stepTextView.font = [UIFont fontWithName:FONT_MuseoSans500 size:11.5f];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveUpdateStep:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans500 size:13.5f]} forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.borderLabel.layer.cornerRadius = 24;
    self.borderLabel.layer.borderColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    self.borderLabel.layer.borderWidth = 1;
    
    self.stepLabel.text = self.stepNumber;
    self.stepTextView.text = self.stepText;    
    [self.stepTextView becomeFirstResponder];
}

#pragma mark - Actions

- (void)closeButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUpdateStep:(UIBarButtonItem *)sender
{
    // save result!
    switch (self.entityName) {
        case PEStepEntityNamePreparation: {
            if (self.specManager.currentPreparation) {
                [self saveUpdatedPreparationNote];
            } else {
                [self saveNewStepToPreparation];
            }
            break;
        }
        case PEStepEntityNameOperationRoom: {
            if (self.specManager.currentStep) {
                [self saveUpdatedStepForOperationRoom];
            } else {
                [self addNewStepForOperationRoom];
            }
            break;
        }
        case PEStepEntityNamePatientPositioning: {
            if (self.specManager.currentStep) {
                [self saveUpdatedStepForPatientPositioning];
            } else {
                [self addNewStepForPatientPositioning];
            }
        }
        default:
            break;
    }
    if (self.stepTextView.text.length) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - Private

- (void)addNewStepForPatientPositioning
{
    if (self.stepTextView.text.length) {
        NSEntityDescription *stepEntityDescription = [NSEntityDescription entityForName:AESStepsEntityName inManagedObjectContext:self.managedObjectContext];
        Steps *newStep = [[Steps alloc] initWithEntity:stepEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        newStep.stepDescription = self.stepTextView.text;
        newStep.stepName = self.stepNumber;
        [self.specManager.currentProcedure.patientPostioning addStepsObject:newStep];
        [self saveToLocalDataBase:AESStepsEntityName];
    } else {
        [self showAlertView];
    }
}

- (void)saveUpdatedStepForPatientPositioning
{
    if (self.specManager.currentStep) {
        if (self.stepTextView.text.length) {
            self.specManager.currentStep.stepDescription = self.stepTextView.text;
            [self saveToLocalDataBase:AESPatientPositioningEntityName];
        } else {
            [self showAlertView];
        }
    }
}

- (void)saveUpdatedStepForOperationRoom
{
    if (self.specManager.currentStep) {
        if (self.stepTextView.text.length) {
            self.specManager.currentStep.stepDescription = self.stepTextView.text;
            [self saveToLocalDataBase:AESOperationRoomEntityName];
        } else {
            [self showAlertView];
        }
    }
}

- (void)addNewStepForOperationRoom
{
    if (self.stepTextView.text.length) {
        NSEntityDescription *stepEntityDescription = [NSEntityDescription entityForName:AESStepsEntityName inManagedObjectContext:self.managedObjectContext];
        Steps *newStep = [[Steps alloc] initWithEntity:stepEntityDescription insertIntoManagedObjectContext:self.managedObjectContext];
        newStep.stepDescription = self.stepTextView.text;
        newStep.stepName = self.stepNumber;
        [self.specManager.currentProcedure.operationRoom addStepsObject:newStep];
        [self saveToLocalDataBase:AESStepsEntityName];
    } else {
        [self showAlertView];
    }
    
}

- (void)saveUpdatedPreparationNote
{
    if (self.specManager.currentPreparation){
        if (self.stepTextView.text.length) {
            self.specManager.currentPreparation.preparationText = self.stepTextView.text;
            [self saveToLocalDataBase:AESPreparationEntityName];
        } else {
            [self showAlertView];
        }
    }
}

- (void)saveNewStepToPreparation
{
    if (self.stepTextView.text.length) {
        NSEntityDescription *preparationEntity = [NSEntityDescription entityForName:AESPreparationEntityName inManagedObjectContext:self.managedObjectContext];
        Preparation *newPreparationStep = [[Preparation alloc] initWithEntity:preparationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newPreparationStep.stepName = self.stepNumber;
        newPreparationStep.preparationText = self.stepTextView.text;
        [self.specManager.currentProcedure addPreparationObject:newPreparationStep];
        [self saveToLocalDataBase:AESPreparationEntityName];
    } else {
        [self showAlertView];
    }
}


- (void)saveToLocalDataBase:(NSString *)entryTypeName
{

    [[PECoreDataManager sharedManager] save];
}

- (void)showAlertView
{
    [[[UIAlertView alloc] initWithTitle:@"Empty step description" message:@"Please add description for step" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

@end
