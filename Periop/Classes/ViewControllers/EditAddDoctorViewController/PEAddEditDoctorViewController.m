//
//  PEAddEditDoctorViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMediaSelect.h"
#import "PEAddEditDoctorViewController.h"
#import "PEEditAddDoctorTableViewCell.h"
#import "PEProceduresTableViewCell.h"
#import "PEAlbumViewController.h"
#import "Procedure.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "Doctors.h"
#import "PECollectionViewCellItemCell.h"
#import "Specialisation.h"
#import "Photo.h"
#import "PEViewPhotoViewController.h"
#import "PECameraViewController.h"


static NSInteger const AEDTitleForRowHeight = 37;
static NSInteger const AEDHeightForSpecRow = 130;
static NSInteger const AEDHeightForAllRows = 37;
static NSInteger const AEDTagForView = 100;
static NSString *const AEDTitleNameSpec = @"Specialisations";

@interface PEAddEditDoctorViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PEEditAddDoctorTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSMutableDictionary * requestedSpecsWithProc;
@property (strong, nonatomic) NSMutableArray * selectedProceduresID;

@end

@implementation PEAddEditDoctorViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEditAddDoctorTableViewCell" bundle:nil] forCellReuseIdentifier:@"tableViewCellWithCollection"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PEProceduresTableViewCell" bundle:nil] forCellReuseIdentifier:@"proceduresCell"];
    self.nameTextField.delegate = self;
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem=saveButton;
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.requestedSpecsWithProc = [[NSMutableDictionary alloc] init];
    self.selectedProceduresID = [[NSMutableArray alloc] init];
    if (self.isEditedDoctor) {
        [self getProcedureIdForSelectedDoctor];
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnPicture:)];
    [self.imageView addGestureRecognizer:tap];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.specManager.photoObject = nil;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *textForHeader;
    if (self.navigationLabelDescription && self.navigationLabelDescription.length>0){
        textForHeader = self.navigationLabelDescription;
    } else {
        textForHeader = @"Add Surgeon";
    }
    ((PENavigationController *)self.navigationController).titleLabel.text = textForHeader;
    
    [[self.view viewWithTag:AEDTagForView] removeFromSuperview];
    
    if (self.isEditedDoctor) {
        self.nameTextField.text = self.specManager.currentDoctor.name;
        if (((Photo*)self.specManager.currentDoctor.photo).photoData!=nil) {
                self.imageView.image = [UIImage imageWithData:((Photo*)self.specManager.currentDoctor.photo).photoData];
        } else {
            self.imageView.image = [UIImage imageNamed:@"Place_Holder.png"];
        }
    }
    
    if (self.specManager.photoObject) {
        self.imageView.image = [UIImage imageWithData:self.specManager.photoObject.photoData];
    }
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (void)tapOnPicture:(UITapGestureRecognizer *)gesture
{
    if ([self.imageView.image hash] != [[UIImage imageNamed:@"Place_Holder.png"] hash]) {
        if (gesture.state == UIGestureRecognizerStateEnded && self.isEditedDoctor) {
            NSLog(@"Touched Image");
            PEViewPhotoViewController * viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
            if (self.specManager.currentDoctor.photo.photoData!=nil) {
                viewPhotoControleller.photoToShow = (Photo*)self.specManager.currentDoctor.photo;
            }
            [self.navigationController pushViewController:viewPhotoControleller animated:YES];
        }
    }
}

-(IBAction)saveButton :(id)sender
{
    NSArray * allSpecs = [NSArray new];
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    allSpecs = [PECoreDataManager getAllEntities:searchedObject];
    
    if (self.isEditedDoctor) {
        for (Procedure * procedure in [self.specManager.currentDoctor.procedure allObjects]) {
            [(Doctors*)self.specManager.currentDoctor removeProcedureObject:procedure];
        }
        for (Specialisation * spec in [self.specManager.currentDoctor.specialisation allObjects]) {
            [(Doctors *)self.specManager.currentDoctor removeSpecialisationObject:spec];
        }
        self.specManager.currentDoctor.name = self.nameTextField.text;
        self.specManager.currentDoctor.createdDate = [NSDate date];
        if (self.imageView.image && self.specManager.photoObject!=nil) {
            self.specManager.currentDoctor.photo = self.specManager.photoObject;
        }
        
        for (Specialisation * spec in allSpecs) {
            BOOL isAdded = NO;
            for (Procedure * proc in [spec.procedures allObjects]) {
                for (int i=0; i<self.selectedProceduresID.count; i++) {
                    if ([proc.procedureID isEqualToString: self.selectedProceduresID[i]]) {
                        [self.specManager.currentDoctor addProcedureObject:proc];
                        isAdded = YES;
                    }
                }
            }
            if (isAdded) {
                [self.specManager.currentDoctor addSpecialisationObject:spec];
            }
        }
    } else {
        NSEntityDescription * doctorsEntity = [NSEntityDescription entityForName:@"Doctors" inManagedObjectContext:self.managedObjectContext];
        Doctors * newDoc = [[Doctors alloc] initWithEntity:doctorsEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        if (self.nameTextField.text.length) {
            newDoc.name = self.nameTextField.text;
        } else {
            newDoc.name = @"No name Doctor";
        }
        newDoc.createdDate = [NSDate date];
        if (self.imageView.image) {
            newDoc.photo = self.specManager.photoObject;
        }
        
        for (Specialisation * spec in allSpecs) {
            BOOL isAdded = NO;
            for (Procedure * proc in [spec.procedures allObjects]) {
                for (int i=0; i<self.selectedProceduresID.count; i++) {
                    if ([proc.procedureID isEqualToString: self.selectedProceduresID[i]]) {
                        [newDoc addProcedureObject:proc];
                        isAdded = YES;
                    }
                }
            }
            if (isAdded) {
                [newDoc addSpecialisationObject:spec];
            }
        }
    }

    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Cant save new doctor, error - %@", saveError.localizedDescription);
    } else {
        NSLog (@"Success");
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhoto:(id)sender
{
    CGRect position = self.imageView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = AEDTagForView;
    [self.view addSubview:view];
}

#pragma mark - UIAction

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    if (!self.isEditedDoctor) {
        albumViewController.navigationLabelText = @"Add photo";
    } else {
        albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentDoctor)).name;
    }
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = DoctorsViewControllerAdd;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0 && indexPath.section == 0) {
        PEEditAddDoctorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCellWithCollection" forIndexPath: indexPath];
        if (!cell) {
            cell = [[PEEditAddDoctorTableViewCell alloc] init];
        }

        cell.delegate = self;
        return cell;
    } else {
        PEProceduresTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"proceduresCell" forIndexPath: indexPath];
        if (!cell) {
            cell = [[PEProceduresTableViewCell alloc] init];
        }
        
        NSArray * keys = [self.requestedSpecsWithProc allKeys];
        NSArray * currentSectionProc = [self.requestedSpecsWithProc objectForKey:keys[indexPath.section - 1 ]];
        
        cell.procedureName.text = ((Procedure*)currentSectionProc[indexPath.row]).name;
        cell.procedureID = ((Procedure*)currentSectionProc[indexPath.row]).procedureID;
        
        if ([self.selectedProceduresID containsObject:cell.procedureID]) {
            [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        return cell;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (!section){
        return 1;
    } else {
        NSArray * keys = [self.requestedSpecsWithProc allKeys];
        NSArray * currentProcArray = [self.requestedSpecsWithProc objectForKey:keys[section - 1 ]];
        return currentProcArray.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (![[self.requestedSpecsWithProc allKeys] count]) {
        return 1;
    } else {
        return [[self.requestedSpecsWithProc allKeys] count] + 1;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(15, 0, self.view.frame.size.width-15, 35);
    myLabel.backgroundColor = [UIColor whiteColor];
    myLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    myLabel.textColor = [UIColor colorWithRed:73/255.0 green:159/255.0 blue:225/255.0 alpha:1.0f];
    if (section==0) {
        myLabel.text = AEDTitleNameSpec;
    } else {
        myLabel.text = [self.requestedSpecsWithProc allKeys][section - 1];
    }
    
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor whiteColor];
    [headerView addSubview:myLabel];
    
    UIView * separatorView = [[UIView alloc] init];
    separatorView.backgroundColor = [UIColor colorWithRed:237/255.0 green:237/255.0 blue:237/255.0 alpha:1.0f];
    separatorView.frame = CGRectMake(0, myLabel.frame.size.height, self.view.frame.size.width, 1);
    
    [headerView addSubview:separatorView];
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return AEDTitleForRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (![indexPath row] && !indexPath.section) {
        return AEDHeightForSpecRow;
    } else {
        return AEDHeightForAllRows;
    }
}

#pragma mark - UITbaleViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        ((PEProceduresTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).checkButton.selected = YES;
        NSArray * keys = [self.requestedSpecsWithProc allKeys];
        NSArray * procForCurrentSection = [self.requestedSpecsWithProc valueForKeyPath:keys[indexPath.section - 1]];
        [self.selectedProceduresID addObject:((Procedure*)procForCurrentSection[indexPath.row]).procedureID];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section) {
        ((PEProceduresTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath]).checkButton.selected = NO;
        NSArray * keys = [self.requestedSpecsWithProc allKeys];
        NSArray * procForCurrentSection = [self.requestedSpecsWithProc valueForKeyPath:keys[indexPath.section - 1]];
        [self.selectedProceduresID removeObject:((Procedure*)procForCurrentSection[indexPath.row]).procedureID];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - PEEditAddDoctorTableViewCellDelegate

- (void)cellSelected:(NSString *)specialisationName
{
    NSLog (@"selected specialisation \"%@\"", specialisationName);
    [self getRequestedSpecsWithProcedures:specialisationName];
    [self.tableView reloadData];
}

- (void)cellUnselected:(NSString *)specialisationName
{
    NSLog (@"Unselected specialisation \"%@\"", specialisationName);
    [self removeRequestedSpecWithProceduresFromDic:specialisationName];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void) getRequestedSpecsWithProcedures: (NSString*) specName
{
    NSArray * allSpecs = [NSArray new];
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    allSpecs = [PECoreDataManager getAllEntities:searchedObject];
    [allSpecs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Specialisation*)obj1 name];
        NSString * secondObject = [(Specialisation*)obj2 name];
        return [firstObject compare:secondObject];
    }];
    NSMutableArray * arrayWithProcsForRequestedSpec = [[NSMutableArray alloc] init];
    for (int i=0; i<allSpecs.count; i++) {
        for (Procedure* proc in [((Specialisation*)allSpecs[i]).procedures allObjects]) {
            if ([((Specialisation*)proc.specialization).name isEqualToString:specName]) {
                [arrayWithProcsForRequestedSpec addObject:proc];
            }
        }
    }
    NSArray *sortedArrayWithProcedures;
    sortedArrayWithProcedures = [arrayWithProcsForRequestedSpec sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * string1 = [(Procedure*)obj1 name];
        NSString * string2 = [(Procedure*)obj2 name];
        return [string1 compare:string2];
    }];
    
    [self.requestedSpecsWithProc setObject:sortedArrayWithProcedures forKey:specName];
}

- (void) removeRequestedSpecWithProceduresFromDic: (NSString*)specName
{
    if ([[self.requestedSpecsWithProc allKeys] containsObject:specName]) {
        [self.requestedSpecsWithProc removeObjectForKey:specName];
    }
}

- (void) getProcedureIdForSelectedDoctor
{
    for (Procedure * proc in [self.specManager.currentDoctor.procedure allObjects]) {
        [self.selectedProceduresID addObject:proc.procedureID];
    }
}

@end
