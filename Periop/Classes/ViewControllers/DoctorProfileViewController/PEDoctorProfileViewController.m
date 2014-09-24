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
#import "PEAlbumViewController.h"
#import "PESpecialisationManager.h"
#import "Procedure.h"
#import "Specialisation.h"
#import <QuartzCore/QuartzCore.h>
#import "PEDoctorProfileCollectionViewCell.h"
#import "Photo.h"

@interface PEDoctorProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UIImageView *doctorPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;

@property (strong, nonatomic) NSArray * doctorsSpec;
@property (strong, nonatomic) NSArray * doctorsProcedures;

@end

@implementation PEDoctorProfileViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"doctorsProfileCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PEDoctorProfileCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"doctorProfileCollectionViewCell"];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.text = ((Specialisation*)self.specManager.currentSpecialisation).name;
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    
    UIBarButtonItem * propButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Edit_Info"] style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    self.navigationItem.rightBarButtonItem=propButton;

    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.doctorName.minimumScaleFactor = 0.5;
    self.doctorName.adjustsFontSizeToFitWidth = YES;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.layer.borderWidth = 0.0f;

}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [[self.view viewWithTag:35] removeFromSuperview];
    
    [self getDoctorsSpecAndProcedures];
    
    self.doctorName.text = self.specManager.currentDoctor.name;
    if (((Photo*)self.specManager.currentDoctor.photo).photoData) {
        self.doctorPhotoImageView.image = [UIImage imageWithData:((Photo*)self.specManager.currentDoctor.photo).photoData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions 

- (IBAction)editButton:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Edit Surgeon";
    addEditDoctorView.isEditedDoctor = true;
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}


- (IBAction)propertiesButtons:(id)sender
{
    PENotesViewController * notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.navigationLabelText = @"Doctors Notes";
    [self.navigationController pushViewController:notesView animated:YES];
}

- (IBAction)detailsButton:(id)sender
{
    
}

- (IBAction)photoButtons:(id)sender
{
    CGRect position = self.doctorPhotoImageView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    NSLog(@"camera Photo from Op");
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.doctorsProcedures[section] count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.doctorsSpec.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"doctorsProfileCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[UITableViewCell alloc] init];
    }
    cell.textLabel.text = ((Procedure*)self.doctorsProcedures[indexPath.section][indexPath.row]).name;
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return ((Procedure*)self.doctorsSpec[section]).name;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.doctorsSpec.count;
}

- (PEDoctorProfileCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEDoctorProfileCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"doctorProfileCollectionViewCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorProfileCollectionViewCell alloc] init];
    }
    cell.imageView.image = [UIImage imageNamed:((Specialisation*)self.doctorsSpec[indexPath.row]).smallIconName];
    return cell;
}

#pragma mark - Private

- (void)getDoctorsSpecAndProcedures
{
    self.doctorsSpec = [self.specManager.currentDoctor.specialisation allObjects];
    
    [self.doctorsSpec sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Specialisation*)obj1 name];
        NSString * secondObject = [(Specialisation*)obj2 name];
        return [firstObject compare:secondObject];
    }];
    
    NSMutableArray * arrayWithArraysOfProceduresForCurrentDoctor = [[NSMutableArray alloc] init];
    
    for (int i=0; i<self.doctorsSpec.count; i++) {
        NSMutableArray * arrayWithProc = [[NSMutableArray alloc] init];
        for (Procedure * proc in [self.specManager.currentDoctor.procedure allObjects]) {
            if ([proc.specialization.name isEqualToString:((Specialisation*)self.doctorsSpec[i]).name]) {
                [arrayWithProc addObject:proc];
            }
        }
        [arrayWithArraysOfProceduresForCurrentDoctor addObject:arrayWithProc];
    }
    self.doctorsProcedures = arrayWithArraysOfProceduresForCurrentDoctor;
}

@end
