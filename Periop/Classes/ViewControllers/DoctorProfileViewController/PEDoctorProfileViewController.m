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
#import "PEObjectDescription.h"
#import "PECoreDataManager.h"
#import "PEViewPhotoViewController.h"
#import "Doctors.h"
#import "PECameraViewController.h"
#import "PEDoctorsProfileTableViewCell.h"

@interface PEDoctorProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UIImageView *doctorPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UIButton *specsButton;

@property (strong, nonatomic) UILabel *navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *doctorsSpec;
@property (strong, nonatomic) NSArray *doctorsProcedures;

@end

@implementation PEDoctorProfileViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.doctorName.font = [UIFont fontWithName:@"MuseoSans-500" size:35.0f];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsProfileTableViewCell" bundle:nil] forCellReuseIdentifier:@"doctorsProfileCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"PEDoctorProfileCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"doctorProfileCollectionViewCell"];
    
    [self.specsButton setImage:[UIImage imageNamed:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.notesButton setImage:[UIImage imageNamed:@"Notes_Tab_Inactive"] forState:UIControlStateNormal];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    
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
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPicture:)];
    [self.doctorPhotoImageView addGestureRecognizer:tap];

}

- (void) viewWillAppear:(BOOL)animated
{
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    [super viewWillAppear:animated];
    self.navigationBarLabel.text = ((Specialisation*)self.specManager.currentSpecialisation).name;
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [[self.view viewWithTag:35] removeFromSuperview];
    
    [self getDoctorsSpecAndProcedures];
    
    self.doctorName.text = self.specManager.currentDoctor.name;
    
    if (((Photo*)self.specManager.currentDoctor.photo).photoData!=nil) {
        self.doctorPhotoImageView.image = [UIImage imageWithData:((Photo*)self.specManager.currentDoctor.photo).photoData];
    } else {
        self.doctorPhotoImageView.image = [UIImage imageNamed:@"Place_Holder.png"];
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
    self.specManager.photoObject = nil;
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions 

- (void)tapOnPicture:(UITapGestureRecognizer *)gesture
{
    if ([self.doctorPhotoImageView.image hash] != [[UIImage imageNamed:@"Place_Holder.png"] hash]) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            NSLog(@"Touched Image");
            PEViewPhotoViewController * viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
            if (self.specManager.currentDoctor.photo.photoData!=nil) {
                viewPhotoControleller.photoToShow = (Photo*)self.specManager.currentDoctor.photo;
            }
            [self.navigationController pushViewController:viewPhotoControleller animated:YES];
        }
    }
}

- (IBAction)editButton:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Edit Surgeon";
    addEditDoctorView.isEditedDoctor = YES;
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}


- (IBAction)propertiesButtons:(id)sender
{
    [self.specsButton setImage:[UIImage imageNamed:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.notesButton setImage:[UIImage imageNamed:@"Notes_Tab_Inactive"] forState:UIControlStateNormal];
    PENotesViewController * notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.navigationLabelText = @"Doctors Notes";
    [self.navigationController pushViewController:notesView animated:YES];
}

- (IBAction)detailsButton:(id)sender
{
    [self.specsButton setImage:[UIImage imageNamed:@"Procedures_Tab_Inactive"] forState:UIControlStateNormal];
    [self.notesButton setImage:[UIImage imageNamed:@"Notes_Tab_Active"] forState:UIControlStateNormal];
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
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentDoctor)).name;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    NSLog(@"camera Photo from Op");
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    [self presentViewController:cameraView animated:YES completion:nil];
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
    PEDoctorsProfileTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"doctorsProfileCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorsProfileTableViewCell alloc] init];
    }
    cell.doctorsNameLabel.text = ((Procedure*)self.doctorsProcedures[indexPath.section][indexPath.row]).name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, self.view.frame.size.width-15, 35);
    myLabel.backgroundColor = [UIColor whiteColor];
    myLabel.font = [UIFont fontWithName:@"MuseoSans_700" size:17.5f];
    myLabel.textColor = [UIColor colorWithRed:73/255.0 green:159/255.0 blue:225/255.0 alpha:1.0f];
    myLabel.text = ((Procedure*)self.doctorsSpec[section]).name;

    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    UIView * separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0f];
    separatorView.frame = CGRectMake(0, myLabel.frame.size.height, 320, 1);

    [headerView addSubview:separatorView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 37;
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
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Doctors" withSortDescriptorKey:@"name"];
    NSArray * allDoctors = [PECoreDataManager getAllEntities:searchedObject];
    
    for (Doctors * doctor in allDoctors) {
        if ([doctor.createdDate isEqualToDate:self.specManager.currentDoctor.createdDate]){
            self.doctorsSpec = [doctor.specialisation allObjects];
        }
    }
    
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
        
        [arrayWithProc sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString* o1 = [(Procedure*)obj1 name];
            NSString* o2 = [(Procedure*)obj2 name];
            return [o1 compare:o2];
        }];
        
        [arrayWithArraysOfProceduresForCurrentDoctor addObject:arrayWithProc];
    }
    self.doctorsProcedures = arrayWithArraysOfProceduresForCurrentDoctor;
}

@end
