//
//  PEProcedureListViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const PLVCCellName = @"doctorsCell";
static NSString *const PLVCNibName = @"PEDoctorsViewTableViewCell";
static NSString *const PLVCStandartCellName = @"Cell";

static NSString *const PLVCProcedureName = @"Procedure Name";
static NSString *const PLVCDoctorsName = @"Doctors Name";
//static NSInteger const PLVCHeightForRow = 53;

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
#import "UIImage+ImageWithJPGFile.h"
#import "PEDoctorsViewTableViewCell.h"

@interface PEProcedureListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, PEDoctorsViewTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *procedureButton;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIBarButtonItem *navigationBarAddDoctorButton;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithProcedures;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithDoctors;
@property (strong, nonatomic) NSMutableSet *currentlySwipedAndOpenesCells;
@property (assign, nonatomic) BOOL isSearchTable;

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
    
    [self.tableView registerNib:[UINib nibWithNibName:PLVCNibName bundle:nil] forCellReuseIdentifier:PLVCCellName];
    
    self.specManager.isProcedureSelected = YES;
    
    [self.procedureButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamedFile:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewDoctor:)];
    self.navigationBarAddDoctorButton = addButton;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.layer.borderWidth = 0.0f;
    //self.currentlySwipedAndOpenesCells = [[NSMutableSet alloc] init];
    self.isSearchTable = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = PLVCProcedureName;
    
    [self.tableView reloadData];
    self.sortedArrayWithProcedures = [self sortedArrayWitProcedures:[self.specManager.currentSpecialisation.procedures allObjects]];
    self.sortedArrayWithDoctors = [self sortedArrayWitDoctors:[self.specManager.currentSpecialisation.doctors allObjects]];
    [self customizingSearchBar];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (self.currentlySwipedAndOpenesCells) {
        [self.currentlySwipedAndOpenesCells removeAllObjects];
    }
}

#pragma mark - IBActions

- (IBAction)procedureButton:(id)sender
{
    ((PENavigationController *)self.navigationController).titleLabel.text = PLVCProcedureName;
    
    self.specManager.isProcedureSelected = YES;
    self.navigationItem.rightBarButtonItem = nil;
    [self.tableView reloadData];
    [self.procedureButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamedFile:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
}

- (IBAction)doctorButton:(id)sender
{
    ((PENavigationController *)self.navigationController).titleLabel.text = self.specManager.currentSpecialisation.name;
    
    self.specManager.isProcedureSelected = NO;
    self.navigationItem.rightBarButtonItem = self.navigationBarAddDoctorButton;
    [self.tableView reloadData];
    [self.procedureButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Inactive"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamedFile:@"Doctors_Tab_Active"] forState:UIControlStateNormal];
}

- (IBAction)addNewDoctor:(id)sender
{
    PEAddEditDoctorViewController *addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}

#pragma mark - Search & UISearchDisplayDelegate

- (void)searchedResult:(NSString *)searchText scope:(NSArray *)scope
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

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView
{
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:[UIColor clearColor]];
    self.isSearchTable = YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didHideSearchResultsTableView:(UITableView *)tableView
{
    self.isSearchTable = NO;
}

- (void) searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4B9DE1)]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)customizingSearchBar
{
    [self.searchBar setBackgroundImage:[[UIImage alloc]init]];

    [self.searchBar setImage:[UIImage imageNamedFile:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamedFile:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    NSArray *searchBarSubViews = [[self.searchBar.subviews objectAtIndex:0] subviews];
    for(int i =0; i<[searchBarSubViews count]; i++) {
        if([[searchBarSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            UITextField *search=(UITextField*)[searchBarSubViews objectAtIndex:i];
            [search setFont:[UIFont fontWithName:FONT_MuseoSans500 size:12.5]];
            [search setTintColor:UIColorFromRGB(0x4D4D4D)];
            search.placeholder = @"Search";
            search.backgroundColor = [UIColor whiteColor];
            search.layer.borderColor = [UIColorFromRGB(0x4B9DE1) CGColor];
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
    UITableViewCell *returnCell = [[UITableViewCell alloc] init];
    
    if (self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.procedures allObjects][indexPath.row]) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVCStandartCellName];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PLVCStandartCellName];
        }
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell.textLabel.text = ((Procedure *)self.searchResult[indexPath.row]).name;
        } else {
            cell.textLabel.text = ((Procedure *)self.sortedArrayWithProcedures[indexPath.row]).name;
        }
        returnCell = cell;
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.doctors allObjects][indexPath.row]) {

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVCStandartCellName];
            if (!cell) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PLVCStandartCellName];
            }
            cell.textLabel.text = ((Doctors *)self.searchResult[indexPath.row]).name;
            returnCell = cell;
        } else {
           PEDoctorsViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVCCellName forIndexPath:indexPath];
            cell.doctorNameLabel.text = ((Doctors *)self.sortedArrayWithDoctors[indexPath.row]).name;
            cell.delegate = self;
            
            if ( indexPath.row % 2){
                cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
                cell.doctorNameLabel.textColor = UIColorFromRGB(0x424242);
            } else {
                cell.viewDoctorsNameView.backgroundColor = UIColorFromRGB(0xE7F5FA);
                cell.doctorNameLabel.textColor = UIColorFromRGB(0x499FE1);
            }
            
            if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]) {
                [cell setCellSwiped];
            }
            returnCell = cell;
        }
    }
    if (self.specManager.isProcedureSelected || (!self.specManager.isProcedureSelected && tableView == self.searchDisplayController.searchResultsTableView)) {
        if ( indexPath.row % 2){
            returnCell.contentView.backgroundColor = [UIColor whiteColor];
            returnCell.textLabel.textColor = UIColorFromRGB(0x424242);
        } else {
            returnCell.contentView.backgroundColor = UIColorFromRGB(0xE7F5FA);
            returnCell.textLabel.textColor = UIColorFromRGB(0x499FE1);
        }
    }
    
    UIFont *cellFont = [UIFont fontWithName:FONT_MuseoSans500 size:15.0];
    returnCell.textLabel.font = cellFont;
    returnCell.textLabel.numberOfLines = 0;
    
    return returnCell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.specManager.isProcedureSelected) {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
             self.specManager.currentProcedure = (Procedure*)self.searchResult[indexPath.row];
        } else {
            for (Procedure *proc in [self.specManager.currentSpecialisation.procedures allObjects]) {
                if ([((Procedure *)self.sortedArrayWithProcedures[indexPath.row]).procedureID isEqualToString:proc.procedureID]) {
                    self.specManager.currentProcedure = proc;
                }
            }
        }
        
        PEProcedureOptionViewController *procedureOptionVIew = [[PEProcedureOptionViewController alloc] initWithNibName:@"PEProcedureOptionViewController" bundle:nil];
        [self.navigationController pushViewController:procedureOptionVIew animated:YES];
        
    } else {
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            self.specManager.currentDoctor = (Doctors *)self.searchResult[indexPath.row];
        } else {
            for (Doctors *doc in [self.specManager.currentSpecialisation.doctors allObjects]) {
                if ([((Doctors *)self.sortedArrayWithDoctors[indexPath.row]).createdDate isEqualToDate:doc.createdDate]) {
                    self.specManager.currentDoctor = doc;
                }
            }
        }
        
        PEDoctorProfileViewController *doctorsView = [[PEDoctorProfileViewController alloc] initWithNibName:@"PEDoctorProfileViewController" bundle:nil];
        [self.navigationController pushViewController:doctorsView animated:YES];
    }
}

#pragma mark - PEDoctorsViewTableViewCellDelegate

- (void)buttonDeleteAction:(UITableViewCell *)cell
{
    NSIndexPath *selectedCellIndexPath = [self.tableView indexPathForCell:cell];
    
    for (Doctors *doc in [self.specManager.currentSpecialisation.doctors allObjects]) {
        if ([((Doctors *)self.sortedArrayWithDoctors[selectedCellIndexPath.row]).createdDate isEqualToDate:doc.createdDate]) {
            [self.managedObjectContext deleteObject:doc];
            NSError *delObj = nil;
            if (![self.managedObjectContext save:&delObj]) {
                NSLog(@"Cant delete doctor");
            }
            [self.currentlySwipedAndOpenesCells removeObject:selectedCellIndexPath];
            self.sortedArrayWithDoctors = [self sortedArrayWitDoctors:[self.specManager.currentSpecialisation.doctors allObjects]];
            [self.tableView reloadData];
            break;
        }
    }
}

- (void)cellDidSwipedOut:(UITableViewCell *)cell
{
    if (!self.isSearchTable) {
        NSIndexPath *currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
        if (!self.currentlySwipedAndOpenesCells) {
            self.currentlySwipedAndOpenesCells = [[NSMutableSet alloc] init];
        }
        [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
    }
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    if (!self.isSearchTable)  {
        [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
    }
}


#pragma marks - Private

- (NSMutableArray *)sortedArrayWitProcedures:(NSArray *)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = ((Procedure *)obj1).name;
        NSString *secondObject = ((Procedure *)obj2).name;
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray *)sortedArrayWitDoctors:(NSArray *)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = ((Doctors *)obj1).name;
        NSString *secondObject = ((Doctors *)obj2).name;
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

@end
