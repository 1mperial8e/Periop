//
//  PEDoctorProfileViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDoctorProfileViewController.h"
#import "PEAddEditDoctorViewController.h"
#import "PENotesViewController.h"
#import "PEMediaSelect.h"

@interface PEDoctorProfileViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UIImageView *doctorPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PEDoctorProfileViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    navigationLabel.text = @"Procedure Name";
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel = navigationLabel;
    
    UIBarButtonItem * propButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(propButton:)];
    self.navigationItem.rightBarButtonItem=propButton;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"doctorsProfileCell"];
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
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions 

- (IBAction)propButton:(id)sender{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Edit Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:NO];
}


- (IBAction)propertiesButtons:(id)sender {
    PENotesViewController * notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.navigationLabelText = @"Doctors Notes";
    [self.navigationController pushViewController:notesView animated:NO];
}

- (IBAction)detailsButton:(id)sender {
}

- (IBAction)photoButtons:(id)sender {
    CGRect position = self.doctorPhotoImageView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

//methods from xib view
- (IBAction)albumPhoto:(id)sender {
    NSLog(@"albumPhoto from Op");
}

- (IBAction)cameraPhoto:(id)sender {
    NSLog(@"camera Photo from Op");
}

- (IBAction)tapOnView:(id)sender {
    NSLog(@"tap on View");
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"doctorsProfileCell" forIndexPath:indexPath];
    if (!cell){
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = @"Procedure";
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Specialization";
}

@end
