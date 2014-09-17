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

@interface PEProcedureOptionViewController ()

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UIButton *equipmentButton;

@end

@implementation PEProcedureOptionViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //make button rounded
    self.equipmentButton.layer.cornerRadius = self.equipmentButton.frame.size.width/2;
    //dimensions of navigationbar
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    //add label to navigation Bar
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    //set text aligment - center
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    navigationLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel = navigationLabel;
    navigationLabel.text = @"Procedure";
    //background
    navigationLabel.backgroundColor = [UIColor clearColor];
    //navigation backButton
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];

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
    preperationView.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
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
