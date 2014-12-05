//
//  PEAddEditProcedureViewController.m
//  ScrubUp
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddEditProcedureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageWithJPGFile.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "PatientPostioning.h"

static CGFloat const AEPCornerRadius = 24;

@interface PEAddEditProcedureViewController ()

@property (weak, nonatomic) IBOutlet UILabel *labelCorners;
@property (weak, nonatomic) IBOutlet UITextView *textViewProcedureName;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;


@end

@implementation PEAddEditProcedureViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.textViewProcedureName.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
    self.labelCorners.layer.cornerRadius = AEPCornerRadius;
    self.labelCorners.layer.borderColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    self.labelCorners.layer.borderWidth = 1;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans500 size:13.5f]} forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((PENavigationController *)self.navigationController).titleLabel.text = self.navigationLabelDescription;
    [self.textViewProcedureName becomeFirstResponder];
    
    if (self.specManager.currentProcedure) {
        self.textViewProcedureName.text = self.specManager.currentProcedure.name;
    }
}

- (void)updateProcedure
{
    if (self.textViewProcedureName.text.length) {
        self.specManager.currentProcedure.name = self.textViewProcedureName.text;
        [[PECoreDataManager sharedManager] save];

        self.specManager.currentProcedure = nil;
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Empty procedure name" message:@"Name can not be empty, please enter \"Procedure Name\"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

- (void)addNewProcedure
{
    if (self.textViewProcedureName.text.length) {
        NSEntityDescription *procedureEntity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:self.managedObjectContext];
        Procedure *newProcForDesctiption = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newProcForDesctiption.name = self.textViewProcedureName.text;

        NSMutableString *newSpecId = [NSMutableString stringWithFormat:@"%i", (int)[self.specManager.currentSpecialisation.procedures allObjects].count + 1];
        if (newSpecId.length == 1) {
            newSpecId = [NSMutableString stringWithFormat:@"0%@",newSpecId];
        }
        NSString *procID = [NSString stringWithFormat:@"%@%@", self.specManager.currentSpecialisation.specID, newSpecId];
        newProcForDesctiption.procedureID = procID;
        
        [self.specManager.currentSpecialisation addProceduresObject:newProcForDesctiption];
        
        NSEntityDescription *operationEntity = [NSEntityDescription entityForName:@"OperationRoom" inManagedObjectContext:self.managedObjectContext];
        OperationRoom *opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        opR.procedure = newProcForDesctiption;
        [newProcForDesctiption setOperationRoom:opR];
        
        NSEntityDescription *patientEntity = [NSEntityDescription entityForName:@"PatientPostioning" inManagedObjectContext:self.managedObjectContext];
        PatientPostioning *pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
        pp.procedure = newProcForDesctiption;
        [newProcForDesctiption setPatientPostioning:pp];
        
        [[PECoreDataManager sharedManager] save];

        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [[[UIAlertView alloc] initWithTitle:@"Empty procedure name" message:@"Name can not be empty, please enter \"Procedure Name\"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
    }
}

#pragma mark - IBActions

- (IBAction)save:(id)sender
{
    if (self.specManager.currentProcedure) {
        [self updateProcedure];
    } else {
        [self addNewProcedure];
    }
}

- (IBAction)closeButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
