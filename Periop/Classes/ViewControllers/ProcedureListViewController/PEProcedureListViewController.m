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

@interface PEProcedureListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) UIBarButtonItem * navigationBarAddDoctorButton;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *procedureButton;

@end

@implementation PEProcedureListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel = navigationLabel;
    navigationLabel.text = @"Procedure Name";
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    navigationLabel.layer.zPosition = 0;
    [self.navigationController.navigationBar addSubview:navigationLabel];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewDoctor:)];
    self.navigationBarAddDoctorButton = addButton;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
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

- (IBAction)menuButton:(id)sender {
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.sizeOfFontInNavLabel = self.navigationBarLabel.font.pointSize;
    menuController.textToShow = @"Procedure Name";
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)procedureButton:(id)sender {
    self.navigationBarLabel.text = @"Procedure Name";
    
    self.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)doctorButton:(id)sender {
    self.navigationBarLabel.text = @"Doctors Name";
    self.navigationItem.rightBarButtonItem = self.navigationBarAddDoctorButton;
}

- (IBAction)addNewDoctor:(id)sender{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:NO];
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 15;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell  =[tableView dequeueReusableCellWithIdentifier:@"Cell" ];
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    if ( indexPath.row % 2){
        cell.contentView.backgroundColor = [UIColor colorWithRed:236/255.0 green:248/255.0 blue:251/255.0 alpha:1.0f];
    }
    else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = [NSString stringWithFormat:@"%i ", (int)indexPath.row ];
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([self.navigationBarLabel.text isEqualToString:@"Procedure Name"]){
        PEProcedureOptionViewController * procedureOptionVIew = [[PEProcedureOptionViewController alloc] initWithNibName:@"PEProcedureOptionViewController" bundle:nil];
        [self.navigationController pushViewController:procedureOptionVIew animated:NO];
    } else if ([self.navigationBarLabel.text isEqualToString:@"Doctors Name"]){
        PEDoctorProfileViewController * doctorsView = [[PEDoctorProfileViewController alloc] initWithNibName:@"PEDoctorProfileViewController" bundle:nil];
        [self.navigationController pushViewController:doctorsView animated:NO];
    }
}

@end
