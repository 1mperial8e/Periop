//
//  PEAddEditStepViewControllerViewController.m
//  Periop
//
//  Created by Stas Volskyi on 16.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddEditStepViewControllerViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PECoreDataManager.h"
#import "PESpecialisationManager.h"
#import "Preparation.h"

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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.specManager.currentPreparation = nil;
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
        case PEStepEntityNamePreparation:
            [self saveUpdatedPreparationNote];
            break;
            
        default:
            break;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Private

- (void)saveUpdatedPreparationNote
{
    if (self.specManager.currentPreparation){
        if (self.stepTextView.text) {
            self.specManager.currentPreparation.preparationText = self.stepTextView.text;
            [self saveToLocalDataBase:@"Preparation"];
        }
    }
}

- (void)saveToLocalDataBase:(NSString *)entryTypeName
{
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Cant save modified %@ - %@", entryTypeName, saveError.localizedDescription);
    }
}

@end
