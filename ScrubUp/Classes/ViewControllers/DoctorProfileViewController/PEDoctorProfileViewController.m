//
//  PEDoctorProfileViewController.m
//  ScrubUp
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
#import "UIImage+ImageWithJPGFile.h"
#import "PEProcedureListViewController.h"
#import "PEBlurEffect.h"

static NSString *const DPDoctorsProfileTableCellName = @"doctorsProfileCell";
static NSString *const DPDoctorsProfileTableNibName = @"PEDoctorsProfileTableViewCell";
static NSString *const DPDoctorsProfileCollectionCellName = @"doctorProfileCollectionViewCell";
static NSString *const DPDoctorsProfileCollectionNibName = @"PEDoctorProfileCollectionViewCell";
static NSString *const DPPlaceHolderImageName = @"Place_Holder";
static NSInteger const DPViewTag = 35;
static NSInteger const DPHeaderHeight = 37;

@interface PEDoctorProfileViewController () <UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *doctorName;
@property (weak, nonatomic) IBOutlet UIImageView *doctorPhotoImageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *notesButton;
@property (weak, nonatomic) IBOutlet UIButton *specsButton;

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

    self.doctorName.font = [UIFont fontWithName:FONT_MuseoSans500 size:35.0f];
    
    [self.tableView registerNib:[UINib nibWithNibName:DPDoctorsProfileTableNibName bundle:nil] forCellReuseIdentifier:DPDoctorsProfileTableCellName];
    [self.collectionView registerNib:[UINib nibWithNibName:DPDoctorsProfileCollectionNibName bundle:nil] forCellWithReuseIdentifier:DPDoctorsProfileCollectionCellName];
    
    [self.specsButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.notesButton setImage:[UIImage imageNamedFile:@"Notes_Tab_Inactive"] forState:UIControlStateNormal];

    UIBarButtonItem *propButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Edit_Info"] style:UIBarButtonItemStyleBordered target:self action:@selector(editButton:)];
    self.navigationItem.rightBarButtonItem=propButton;

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.doctorName.minimumScaleFactor = 0.5;
    self.doctorName.adjustsFontSizeToFitWidth = YES;
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.layer.borderWidth = 0.0f;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPicture:)];
    [self.doctorPhotoImageView addGestureRecognizer:tap];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = self.specManager.currentDoctor.name;;
    
    [(PEMediaSelect *)[self.view viewWithTag:DPViewTag] setVisible:NO];
    
    [self getDoctorsSpecAndProcedures];
    
    self.doctorName.text = self.specManager.currentDoctor.name;
    
    if (((Photo*)self.specManager.currentDoctor.photo).photoData) {
        UIImage *image = [UIImage imageWithData:((Photo*)self.specManager.currentDoctor.photo).photoData];
        self.doctorPhotoImageView.image = image;
    } else {
        self.doctorPhotoImageView.image = [UIImage imageNamedFile:DPPlaceHolderImageName];
    }
    
    [self.tableView reloadData];
    [self.collectionView reloadData];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (void)tapOnPicture:(UITapGestureRecognizer *)gesture
{
    if (((Photo *)self.specManager.currentDoctor.photo).photoData) {
        if (gesture.state == UIGestureRecognizerStateEnded) {
            self.navigationController.navigationBar.translucent = YES;
            PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
            if (self.specManager.currentDoctor.photo.photoData!=nil) {
                viewPhotoControleller.photoToShow = (Photo*)self.specManager.currentDoctor.photo;
            }
            [self.navigationController pushViewController:viewPhotoControleller animated:YES];
        }
    }
}

- (IBAction)editButton:(id)sender
{
    PEAddEditDoctorViewController *addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Edit Surgeon";
    addEditDoctorView.isEditedDoctor = YES;
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}


- (IBAction)propertiesButtons:(id)sender
{
    PENotesViewController *notesView = [[PENotesViewController alloc] initWithNibName:@"PENotesViewController" bundle:nil];
    notesView.isDoctorsNote = YES;
    self.specManager.isProcedureSelected = NO;
    notesView.navigationLabelText = @"Doctors Notes";
    [self.navigationController pushViewController:notesView animated:NO];
}

- (IBAction)detailsButton:(id)sender
{
    //dummy
}

- (IBAction)photoButtons:(id)sender
{
    CGRect position = self.doctorPhotoImageView.frame;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = array[0];
    view.frame = position;
    view.tag = DPViewTag;
    [self.view addSubview:view];
    [view setVisible:YES];
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
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = DoctorsViewControllerProfile;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [(PEMediaSelect *)[self.view viewWithTag:DPViewTag] setVisible:NO];
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
    PEDoctorsProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:DPDoctorsProfileTableCellName forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorsProfileTableViewCell alloc] init];
    }
    cell.doctorsNameLabel.text = ((Procedure*)self.doctorsProcedures[indexPath.section][indexPath.row]).name;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, self.view.frame.size.width-15, 35);
    myLabel.backgroundColor = [UIColor whiteColor];
    myLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    myLabel.textColor = UIColorFromRGB(0x499FE1);
    myLabel.text = ((Procedure *)self.doctorsSpec[section]).name;

    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    
    UIView *separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = UIColorFromRGB(0xEDEDED);
    separatorView.frame = CGRectMake(0, myLabel.frame.size.height, 320, 1);

    [headerView addSubview:separatorView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return DPHeaderHeight;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.doctorsSpec.count;
}

- (PEDoctorProfileCollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEDoctorProfileCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:DPDoctorsProfileCollectionCellName forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorProfileCollectionViewCell alloc] init];
    }
    cell.imageView.image = [UIImage imageNamedFile:((Specialisation*)self.doctorsSpec[indexPath.row]).smallIconName];
    return cell;
}

#pragma mark - Private

- (void)getDoctorsSpecAndProcedures
{
    PEObjectDescription *searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Doctors" withSortDescriptorKey:@"name"];
    NSArray *allDoctors = [PECoreDataManager getAllEntities:searchedObject];
    
    for (Doctors *doctor in allDoctors) {
        if ([doctor.createdDate isEqualToDate:self.specManager.currentDoctor.createdDate]){
            self.doctorsSpec = [[doctor.specialisation allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *firstObject = ((Specialisation *)obj1).name;
                NSString *secondObject = ((Specialisation *)obj2).name;
                return [firstObject compare:secondObject];
            }];
            break;
        }
    }
    
    NSMutableArray *arrayWithArraysOfProceduresForCurrentDoctor = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < self.doctorsSpec.count; i++) {
        NSMutableArray *arrayWithProc = [[NSMutableArray alloc] init];
        for (Procedure *proc in [self.specManager.currentDoctor.procedure allObjects]) {
            if ([proc.specialization.name isEqualToString:((Specialisation*)self.doctorsSpec[i]).name]) {
                [arrayWithProc addObject:proc];
            }
        }
        
        [arrayWithProc sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *o1 = ((Procedure *)obj1).name;
            NSString *o2 = ((Procedure *)obj2).name;
            return [o1 compare:o2];
        }];
        
        [arrayWithArraysOfProceduresForCurrentDoctor addObject:arrayWithProc];
    }
    NSArray *sortedArray = [arrayWithArraysOfProceduresForCurrentDoctor sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSArray *arr1 = obj1;
        NSArray *arr2 = obj2;
        NSString *specNameForArray1 = ((Procedure *)arr1[0]).specialization.name;
        NSString *specNameForArray2 = ((Procedure *)arr2[0]).specialization.name;
        return [specNameForArray1 compare:specNameForArray2];
    }];
    
    self.doctorsProcedures = sortedArray;
}

@end
