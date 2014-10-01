//
//  PEProcedureListViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const PLVCProcedureName = @"Procedure Name";
static NSString *const PLVCDoctorsName = @"Doctors Name";

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
#import "UIImage+fixOrientation.h"

@interface PEProcedureListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *procedureButton;

@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) UIBarButtonItem * navigationBarAddDoctorButton;
@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithProcedures;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithDoctors;

@property (strong, nonatomic) NSArray *searchResult;

@end

@implementation PEProcedureListViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.specManager.isProcedureSelected = YES;
    
    [self.procedureButton setImage:[UIImage imageNamed:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamed:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width / 2, navBarSize.height / 2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0];
    self.navigationBarLabel.text = PLVCProcedureName;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.layer.zPosition = 0;
    self.navigationBarLabel.numberOfLines = 0;
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewDoctor:)];
    self.navigationBarAddDoctorButton = addButton;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.layer.borderWidth = 0.0f;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [self.tableView reloadData];
    self.sortedArrayWithProcedures = [self sortedArrayWitProcedures:[self.specManager.currentSpecialisation.procedures allObjects]];
    self.sortedArrayWithDoctors = [self sortedArrayWitDoctors:[self.specManager.currentSpecialisation.doctors allObjects]];
    [self customizingSearchBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)procedureButton:(id)sender
{
    self.navigationBarLabel.text = PLVCProcedureName;
    self.specManager.isProcedureSelected = true;
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
    [self.procedureButton setImage:[UIImage imageNamed:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamed:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
}

- (IBAction)doctorButton:(id)sender
{
    self.specManager.isProcedureSelected = false;
    self.navigationBarLabel.text = PLVCDoctorsName;
    self.navigationItem.rightBarButtonItem = self.navigationBarAddDoctorButton;
    [self.tableView reloadData];
    [self.procedureButton setImage:[UIImage imageNamed:@"Procedures_Tab_Inactive"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamed:@"Doctors_Tab_Active"] forState:UIControlStateNormal];
}

- (IBAction)addNewDoctor:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}

#pragma mark - Search & UISearchDisplayDelegate

- (void)searchedResult: (NSString*)searchText scope:(NSArray*)scope
{
    NSPredicate *resultPredicat = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    if (self.specManager.isProcedureSelected) {
        self.searchResult = [[self.specManager.currentSpecialisation.procedures allObjects] filteredArrayUsingPredicate:resultPredicat];
    } else {
        self.searchResult = [[self.specManager.currentSpecialisation.doctors allObjects] filteredArrayUsingPredicate:resultPredicat];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchedResult:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:[UIColor clearColor]];
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed: 75/255.0 green:157/255.0 blue:225/255.0 alpha: 1.0f]]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed: 255/255.0 green:255/255.0 blue:255/255.0 alpha: 1.0f]]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)customizingSearchBar
{
    [self.searchBar setBackgroundImage:[[UIImage alloc]init]];

    [self.searchBar setImage:[UIImage imageNamed:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamed:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    NSArray *searchBarSubViews = [[self.searchBar.subviews objectAtIndex:0] subviews];
    for(int i =0; i<[searchBarSubViews count]; i++) {
        if([[searchBarSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            UITextField* search=(UITextField*)[searchBarSubViews objectAtIndex:i];
            [search setFont:[UIFont fontWithName:FONT_MuseoSans500 size:12.5]];
            [search setTintColor:[UIColor colorWithRed:77/255.0 green:77/255.0 blue:77/255.0 alpha:1.0f]];
            search.placeholder = @"Search";
            search.backgroundColor = [UIColor whiteColor];
            search.layer.borderColor = [[UIColor colorWithRed:75/255.0 green:157/255.0 blue:225/255.0 alpha:1.0f] CGColor];
            search.layer.borderWidth = 1.0f;
            search.layer.cornerRadius = 8.0f;
            search.alpha =1.0f;
            search.leftViewMode = UITextFieldViewModeNever;
        }
    }
    
}

#pragma mark - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResult.count;
    } else if (self.specManager.isProcedureSelected) {
        return [self.specManager.currentSpecialisation.procedures count];
    } else {
        return [self.specManager.currentSpecialisation.doctors count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    if ( indexPath.row % 2){
        cell.contentView.backgroundColor = [UIColor colorWithRed:(231.0/255.0) green:(245.0/255.0) blue:(250.0/255.0) alpha:1.0f];
        cell.textLabel.textColor = [UIColor colorWithRed:(73.0/255.0) green:(159.0/255.0) blue:(225.0/255.0) alpha:1.0f];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        cell.textLabel.textColor = [UIColor colorWithRed:(66.0/255.0) green:(66.0/255.0) blue:(66.0/255.0) alpha:1.0f];
    }
    
    UIFont *cellFont = [UIFont fontWithName:FONT_MuseoSans500 size:15.0];
    if (self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.procedures allObjects][indexPath.row]!=nil) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell.textLabel.text = ((Procedure*)self.searchResult[indexPath.row]).name;
        } else {
            cell.textLabel.text = ((Procedure*)self.sortedArrayWithProcedures[indexPath.row]).name;
        }
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.doctors allObjects][indexPath.row]!=nil) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell.textLabel.text = ((Doctors*)self.searchResult[indexPath.row]).name;
        } else {
            cell.textLabel.text = ((Doctors*)self.sortedArrayWithDoctors[indexPath.row]).name;
        }
    }
    cell.textLabel.font = cellFont;
    cell.textLabel.numberOfLines = 0;
    return cell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.specManager.isProcedureSelected) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
             self.specManager.currentProcedure = (Procedure*)self.searchResult[indexPath.row];
        } else {
            for (Procedure* proc in [self.specManager.currentSpecialisation.procedures allObjects]) {
                if ([((Procedure*)self.sortedArrayWithProcedures[indexPath.row]).procedureID isEqualToString:proc.procedureID]) {
                    self.specManager.currentProcedure = proc;
                }
            }
        }
        
        PEProcedureOptionViewController * procedureOptionVIew = [[PEProcedureOptionViewController alloc] initWithNibName:@"PEProcedureOptionViewController" bundle:nil];
        [self.navigationController pushViewController:procedureOptionVIew animated:YES];
        
    } else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            self.specManager.currentDoctor = (Doctors*)self.searchResult[indexPath.row];
        } else {
            for (Doctors* doc in [self.specManager.currentSpecialisation.doctors allObjects]) {
                if ([((Doctors*)self.sortedArrayWithDoctors[indexPath.row]).createdDate isEqualToDate:doc.createdDate]) {
                    self.specManager.currentDoctor = doc;
                }
            }
        }
        
        PEDoctorProfileViewController * doctorsView = [[PEDoctorProfileViewController alloc] initWithNibName:@"PEDoctorProfileViewController" bundle:nil];
        [self.navigationController pushViewController:doctorsView animated:YES];
    }
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 53;
}


#pragma marks - Private

- (NSMutableArray *)sortedArrayWitProcedures: (NSArray*)arrayToSort
{
    NSArray * sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Procedure*)obj1 name];
        NSString *  secondObject = [(Procedure*)obj2 name];
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray *)sortedArrayWitDoctors: (NSArray*)arrayToSort
{
    NSArray * sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Doctors*)obj1 name];
        NSString *  secondObject = [(Doctors*)obj2 name];
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}


@end
