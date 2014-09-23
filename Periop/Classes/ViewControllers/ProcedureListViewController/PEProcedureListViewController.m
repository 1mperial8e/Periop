//
//  PEProcedureListViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PEProcedureListViewController.h"
#import "PEMenuViewController.h"
#import "PEProcedureOptionViewController.h"
#import "PEDoctorProfileViewController.h"
#import "PEAddEditDoctorViewController.h"
#import "PESpecialisationViewController.h"
#import "Doctors.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "Procedure.h"

@interface PEProcedureListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *procedureButton;

@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) UIBarButtonItem * navigationBarAddDoctorButton;
@property (strong, nonatomic) UILabel * navigationBarLabel;

@end

@implementation PEProcedureListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.specManager.isProcedureSelected = true;
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.text = @"Procedure Name";
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.layer.zPosition = 0;
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewDoctor:)];
    self.navigationBarAddDoctorButton = addButton;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)procedureButton:(id)sender
{
    self.navigationBarLabel.text = @"Procedure Name";
    self.specManager.isProcedureSelected = true;
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
}

- (IBAction)doctorButton:(id)sender
{
    self.specManager.isProcedureSelected = false;
    self.navigationBarLabel.text = @"Doctors Name";
    self.navigationItem.rightBarButtonItem = self.navigationBarAddDoctorButton;
    [self.tableView reloadData];
}

- (IBAction)addNewDoctor:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.specManager.isProcedureSelected) {
        return [self.specManager.currentSpecialisation.procedures count];
    } else {
        return [self.specManager.currentSpecialisation.doctors count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell  =[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    if ( indexPath.row % 2){
        cell.contentView.backgroundColor = [UIColor colorWithRed:236/255.0 green:248/255.0 blue:251/255.0 alpha:1.0f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    
    if (self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.procedures allObjects][indexPath.row]!=nil) {
        cell.textLabel.text = ((Procedure*)[self.specManager.currentSpecialisation.procedures allObjects][indexPath.row]).name;
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.doctors allObjects][indexPath.row]!=nil) {
        cell.textLabel.text = ((Doctors*)[self.specManager.currentSpecialisation.doctors allObjects][indexPath.row]).name;
    }
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentProcedure = [self.specManager.currentSpecialisation.procedures allObjects][indexPath.row];
        PEProcedureOptionViewController * procedureOptionVIew = [[PEProcedureOptionViewController alloc] initWithNibName:@"PEProcedureOptionViewController" bundle:nil];
        [self.navigationController pushViewController:procedureOptionVIew animated:YES];
        
    } else {
        self.specManager.currentDoctor = [self.specManager.currentSpecialisation.doctors allObjects][indexPath.row];
        PEDoctorProfileViewController * doctorsView = [[PEDoctorProfileViewController alloc] initWithNibName:@"PEDoctorProfileViewController" bundle:nil];
        [self.navigationController pushViewController:doctorsView animated:YES];
    }
}

@end
