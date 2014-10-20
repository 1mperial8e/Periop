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
#import "PEAddEditProcedureViewController.h"

@interface PEProcedureOptionViewController ()

@property (strong, nonatomic) PESpecialisationManager *specManager;

@property (weak, nonatomic) IBOutlet UIButton *preparationButton;
@property (weak, nonatomic) IBOutlet UIButton *operationRoomButton;
@property (weak, nonatomic) IBOutlet UIButton *patientPostioningButton;
@property (weak, nonatomic) IBOutlet UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UIButton *equipmentButton;

@property (assign, nonatomic) CGFloat distance;

@end

@implementation PEProcedureOptionViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    [self setupButtons];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.specManager.isProcedureSelected = YES;
    ((PENavigationController *)self.navigationController).titleLabel.text = ((Procedure *)self.specManager.currentProcedure).name;
}

#pragma mark - Equipment Rounded Button

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{   
    touches = [event touchesForView:self.equipmentButton];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.equipmentButton];
    CGPoint center = CGPointMake(self.equipmentButton.bounds.size.height / 2, self.equipmentButton.bounds.size.width / 2);
    CGFloat distance = [self distanceBetweenTwoPoints:center toPoint:touchPoint];
    if (distance < self.equipmentButton.frame.size.width / 2) {
        [self.equipmentButton setHighlighted:YES];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    touches = [event touchesForView:self.equipmentButton];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.equipmentButton];
    CGPoint center = CGPointMake(self.equipmentButton.bounds.size.height / 2, self.equipmentButton.bounds.size.width / 2);
    CGFloat distance = [self distanceBetweenTwoPoints:center toPoint:touchPoint];
    if (distance < self.equipmentButton.frame.size.width / 2) {
        [self.equipmentButton setHighlighted:NO];
        [self performSelector:@selector(goToEquipmentViewController)];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    touches = [event touchesForView:self.equipmentButton];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self.equipmentButton];
    CGPoint center = CGPointMake(self.equipmentButton.bounds.size.height / 2, self.equipmentButton.bounds.size.width / 2);
    CGFloat distance = [self distanceBetweenTwoPoints:center toPoint:touchPoint];
    if (distance < self.equipmentButton.frame.size.width / 2) {
        [self.equipmentButton setHighlighted:NO];
        [self performSelector:@selector(goToEquipmentViewController)];
    }
}

- (void) goToEquipmentViewController
{
    PEEquipmentViewController *equipmentView = [[PEEquipmentViewController alloc] initWithNibName:@"PEEquipmentViewController" bundle:nil];
    [self.navigationController pushViewController:equipmentView animated:YES];
}

#pragma mark - IBActions

- (IBAction)preparationButton:(id)sender
{
    PEPreperationViewController *preperationView = [[PEPreperationViewController alloc] initWithNibName:@"PEPreperationViewController" bundle:nil];
    [self.navigationController pushViewController:preperationView animated:YES];
}

- (IBAction)operationRoomButton:(id)sender
{
    PEOperationRoomViewController *operationRoomView = [[PEOperationRoomViewController alloc] initWithNibName:@"PEOperationRoomViewController" bundle:nil];
    [self.navigationController pushViewController:operationRoomView animated:YES];
}

- (IBAction)patientPositioningButton:(id)sender
{
    PEPatientPositioningViewController *patientPositioningView = [[PEPatientPositioningViewController alloc] initWithNibName:@"PEPatientPositioningViewController" bundle:nil];
    [self.navigationController pushViewController:patientPositioningView animated:YES];
}

- (IBAction)notesButton:(id)sender
{
    PENotesViewController *notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.navigationLabelText = @"Procedure Notes";
    [self.navigationController pushViewController:notesView animated:YES];
}

- (IBAction)doctorsButton:(id)sender
{
    PEDoctorsListViewController *doctorsView = [[PEDoctorsListViewController alloc] initWithNibName:@"PEDoctorsListViewController" bundle:nil];
    doctorsView.textToShow = self.specManager.currentProcedure.name;
    doctorsView.isButtonRequired = false;
    [self.navigationController pushViewController:doctorsView animated:YES];
}

#pragma mark - Private

- (void)setupButtons
{
    UIFont *buttonsFont = [UIFont fontWithName:FONT_MuseoSans500 size:17.0];
    self.operationRoomButton.titleLabel.font = buttonsFont;
    self.preparationButton.titleLabel.font = buttonsFont;
    self.patientPostioningButton.titleLabel.font = buttonsFont;
    self.notesButton.titleLabel.font = buttonsFont;
    self.equipmentButton.titleLabel.font = buttonsFont;
    
    self.operationRoomButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.preparationButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.patientPostioningButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.notesButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.equipmentButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [self.operationRoomButton setTitle:@"Operating\n Room" forState:UIControlStateNormal];
    [self.patientPostioningButton setTitle:@"Patient\n Positioning" forState:UIControlStateNormal];
}

- (CGFloat)distanceBetweenTwoPoints:(CGPoint)point1 toPoint:(CGPoint)point2
{
    CGFloat dx = point2.x - point1.x;
    CGFloat dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy );
}

@end
