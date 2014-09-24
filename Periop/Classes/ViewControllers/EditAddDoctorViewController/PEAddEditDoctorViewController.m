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

@interface PEAddEditDoctorViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, PEEditAddDoctorTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@property (strong, nonatomic) NSArray * avaliableSpecs;
@property (strong, nonatomic) NSMutableArray * allGrouppedProcedures;

@property (strong, nonatomic) NSArray * doctorsSpec;
@property (strong, nonatomic) NSArray * doctorsProcedures;

@property (strong, nonatomic) NSMutableArray * requestedSpecs;

@end

@implementation PEAddEditDoctorViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEditAddDoctorTableViewCell" bundle:nil] forCellReuseIdentifier:@"tableViewCellWithCollection"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PEProceduresTableViewCell" bundle:nil] forCellReuseIdentifier:@"proceduresCell"];
    self.nameTextField.delegate = self;
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    if (self.navigationLabelDescription && self.navigationLabelDescription.length>0){
        self.navigationBarLabel.text=self.navigationLabelDescription;
    } else {
        self.navigationBarLabel.text = @"Add Surgeon";
    }
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem=saveButton;
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.nameTextField.text = self.specManager.currentDoctor.name;
    
    [self getAvaliableSpecs];
    [self getDoctorsSpecAndProcedures];
    self.requestedSpecs = [[NSMutableArray alloc] init];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

#pragma mark - IBActions

-(IBAction)saveButton :(id)sender
{
    if (self.isEditedDoctor) {
        self.specManager.currentDoctor.name = self.nameTextField.text;
    } else {
        NSEntityDescription * doctorsEntity = [NSEntityDescription entityForName:@"Doctors" inManagedObjectContext:self.managedObjectContext];
        Doctors * newDoc = [[Doctors alloc] initWithEntity:doctorsEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newDoc.name = self.nameTextField.text;
        newDoc.createdDate = [NSDate date];
#warning add spec - crash if add from surgeon list
        [newDoc addSpecialisationObject:self.specManager.currentSpecialisation];
    }
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Cant save new doctor, error - %@", saveError.localizedDescription);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)addPhoto:(id)sender
{
    CGRect position = self.imageView.frame;
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
    NSLog(@"camera Photo");
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

- (IBAction)addPhotoFromCamera:(id)sender
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0){
        return 1;
    } else {
        return [self.allGrouppedProcedures[section - 1 ] count];
    }
}

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
        cell.textLabel.text = ((Procedure *)self.allGrouppedProcedures[indexPath.section - 1 ][indexPath.row]).name;
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0 && indexPath.section == 0) {
        return 130;
    } else {
        return 64.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.requestedSpecs.count == 0) {
        return 1;
    } else {
        return self.allGrouppedProcedures.count+1;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section==0) {
        return @"Procedures";
    } else {
        return ((NSString*)self.requestedSpecs[section - 1 ]);
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
    [self.requestedSpecs addObject:specialisationName];
    [self getRequestedProceduresForSpecialisations:self.requestedSpecs];
    [self.tableView reloadData];
}

- (void)cellUnselected:(NSString *)specialisationName
{
    NSLog (@"Unselected specialisation \"%@\"", specialisationName);
    if (self.requestedSpecs.count>0 && [self.requestedSpecs containsObject:specialisationName]) {
        [self.requestedSpecs removeObject:specialisationName];
    }
    [self getRequestedProceduresForSpecialisations:self.requestedSpecs];
    [self.tableView reloadData];
}

#pragma mark - Private

- (void) getAvaliableSpecs
{
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.avaliableSpecs = [PECoreDataManager getAllEntities:searchedObject];
    
    [self.avaliableSpecs sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Specialisation*)obj1 name];
        NSString * secondObject = [(Specialisation*)obj2 name];
        return [firstObject compare:secondObject];
    }];
}

- (void)getRequestedProceduresForSpecialisations: (NSArray* )filteredArray
{
    //arr2 - all procedures
    NSMutableArray * grouppedProcedures = [[NSMutableArray alloc] init];
    
    //1.sort filtered array
    //2. filtered array - count of section
    //3. resulted array with sorted proc - count of rows in section
    //4. name of title - from filtered array
    //5. title for rows - from array with sorted proc
    
    //1
    if (filteredArray.count>0){
        [filteredArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *ob1 = obj1;
            NSString *ob2 = obj2;
            return [ob1 compare:ob2];
        }];
        for (int i=0; i<filteredArray.count; i++) {
            for (int j=0; j<self.avaliableSpecs.count; j++) {
                NSMutableArray * arrayWithProc = [[NSMutableArray alloc] init];
                NSArray *arrWithAllProceduresForCurrentSpec = [((Specialisation*)self.avaliableSpecs[j]).procedures allObjects];
                for (Procedure * proc in arrWithAllProceduresForCurrentSpec) {
                    //here put filter by name
                    if ([proc.specialization.name isEqualToString:((NSString*)filteredArray[i])] ) {
                        [arrayWithProc addObject:proc];
                    }
                }
                if (arrayWithProc.count>0){
                    [grouppedProcedures addObject:arrayWithProc];
                }
            }
        }
        [self.allGrouppedProcedures removeAllObjects];
        self.allGrouppedProcedures = grouppedProcedures;
    } else {
        [self.allGrouppedProcedures removeAllObjects];
    }
}

- (void)getDoctorsSpecAndProcedures
{
    //ARRAY WITH SORTED A-Z ALL SPEC FOR CURRENT DOCTOR
    self.doctorsSpec = [self.specManager.currentDoctor.specialisation allObjects];
    
    [self.doctorsSpec sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Specialisation*)obj1 name];
        NSString * secondObject = [(Specialisation*)obj2 name];
        return [firstObject compare:secondObject];
    }];
    
    //ARRAY WITH SORTED A-Z ARRAY WITH PROC FOR EACH SPEC
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
