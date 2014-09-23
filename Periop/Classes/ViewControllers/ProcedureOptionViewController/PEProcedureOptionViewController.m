//
//  PEProcedureOptionViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEProcedureOptionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PEPreperationViewController.h"
#import "PEOperationRoomViewController.h"
#import "PEPatientPositioningViewController.h"
#import "PENotesViewController.h"
#import "PEEquipmentViewController.h"
#import "PEDoctorsListViewController.h"
#import "Procedure.h"
#import "PESpecialisationManager.h"

@interface PEProcedureOptionViewController ()

@property (weak, nonatomic) IBOutlet UIButton *equipmentButton;
@property (weak, nonatomic) IBOutlet UIView *mainView;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;

@end

@implementation PEProcedureOptionViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.text = ((Procedure*)self.specManager.currentProcedure).name;
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.equipmentButton.layer.cornerRadius = self.equipmentButton.frame.size.width/2;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)preparationButton:(id)sender {
    PEPreperationViewController * preperationView = [[PEPreperationViewController alloc] initWithNibName:@"PEPreperationViewController" bundle:nil];
    [self.navigationController pushViewController:preperationView animated:YES];
}

- (IBAction)operationRoomButton:(id)sender {
    PEOperationRoomViewController * operationRoomView = [[PEOperationRoomViewController alloc] initWithNibName:@"PEOperationRoomViewController" bundle:nil];
    [self.navigationController pushViewController:operationRoomView animated:YES];
}

- (IBAction)equipmentButton:(id)sender {
    PEEquipmentViewController * equipmentView = [[PEEquipmentViewController alloc] initWithNibName:@"PEEquipmentViewController" bundle:nil];
    [self.navigationController pushViewController:equipmentView animated:YES];

}

- (IBAction)patientPositioningButton:(id)sender {
    PEPatientPositioningViewController * patientPositioningView = [[PEPatientPositioningViewController alloc] initWithNibName:@"PEPatientPositioningViewController" bundle:nil];
    [self.navigationController pushViewController:patientPositioningView animated:YES];
}

- (IBAction)notesButton:(id)sender {
    PENotesViewController * notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.navigationLabelText = @"Procedure Notes";
    [self.navigationController pushViewController:notesView animated:YES];
}

- (IBAction)doctorsButton:(id)sender {
    PEDoctorsListViewController * doctorsView = [[PEDoctorsListViewController alloc] initWithNibName:@"PEDoctorsListViewController" bundle:nil];
    doctorsView.textToShow = @"Procedure Name";
    doctorsView.isButtonRequired = false;
    [self.navigationController pushViewController:doctorsView animated:YES];
}
@end
