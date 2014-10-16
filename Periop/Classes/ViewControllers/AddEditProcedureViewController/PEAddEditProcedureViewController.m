//
//  PEAddEditProcedureViewController.m
//  Periop
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const AEPWindowName = @"Edit Procedure Name";
static CGFloat const AEPCornerRadius = 24;

#import "PEAddEditProcedureViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageWithJPGFile.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"

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
    self.labelCorners.layer.cornerRadius = 24;
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
    ((PENavigationController *)self.navigationController).titleLabel.text = AEPWindowName;
    [self.textViewProcedureName becomeFirstResponder];
    
    if (self.specManager.currentProcedure) {
        self.textViewProcedureName.text = self.specManager.currentProcedure.name;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.specManager.currentProcedure = nil;
}

#pragma mark - IBActions

- (IBAction)save:(id)sender
{
    if (self.textViewProcedureName.text.length) {
        self.specManager.currentProcedure.name = self.textViewProcedureName.text;
        NSError * saveError = nil;
        if (![self.managedObjectContext save:&saveError]) {
            NSLog(@"Cant save modified name of Procedure - %@", saveError.localizedDescription);
        }
    } else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Empty procedure name" message:@"Name can not be empty, please enter \"Procedure Name\"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)closeButton:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


@end
