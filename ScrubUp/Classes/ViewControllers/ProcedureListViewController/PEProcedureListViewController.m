//
//  PEProcedureListViewController.m
//  ScrubUp
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
#import "UIImage+fixOrientation.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PEDoctorsViewTableViewCell.h"
#import "PEProcedureListTableViewCell.h"
#import "PEAddEditProcedureViewController.h"

static NSString *const PLVCCellName = @"doctorsCell";
static NSString *const PLVCNibName = @"PEDoctorsViewTableViewCell";
static NSString *const PLVCProcedureTableViewCellIdentifier = @"procedureListTableViewCell";
static NSString *const PLVCProcedureTableViewCellNibName = @"PEProcedureListTableViewCell";
static CGFloat const PLVCHeighForCell = 53.0f;

@interface PEProcedureListViewController () <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, PEDoctorsViewTableViewCellDelegate, PEProcedureListTableViewCellGestrudeDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *doctorsButton;
@property (weak, nonatomic) IBOutlet UIButton *procedureButton;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) UIBarButtonItem *navigationBarAddDoctorButton;
@property (strong, nonatomic) UIBarButtonItem *addProcedureButton;

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
    [self.tableView registerNib:[UINib nibWithNibName:PLVCProcedureTableViewCellNibName bundle:nil] forCellReuseIdentifier:PLVCProcedureTableViewCellIdentifier];
    
    self.specManager.isProcedureSelected = YES;
    
    [self.procedureButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamedFile:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewDoctor:)];
    self.navigationBarAddDoctorButton = addButton;
    self.addProcedureButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewProcedure:)];
    self.navigationItem.rightBarButtonItem = self.addProcedureButton;
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.layer.borderWidth = 0.0f;
    self.isSearchTable = NO;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = self.specManager.currentSpecialisation.name;

    [self customizingSearchBar];
    
    if (!self.specManager.isProcedureSelected) {
        [self doctorsSelected];
    }
    
    self.specManager.currentProcedure = nil;
    [self refreshData];
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
    [self.currentlySwipedAndOpenesCells removeAllObjects];
    
    self.specManager.isProcedureSelected = YES;
    self.navigationItem.rightBarButtonItem = self.addProcedureButton;
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.procedureButton setImage:[UIImage imageNamedFile:@"Procedures_Tab_Active"] forState:UIControlStateNormal];
    [self.doctorsButton setImage:[UIImage imageNamedFile:@"Doctors_Tab_Inactive"] forState:UIControlStateNormal];
}

- (IBAction)doctorButton:(id)sender
{
    [self doctorsSelected];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)doctorsSelected
{
    [self.currentlySwipedAndOpenesCells removeAllObjects];
    
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

- (IBAction)addNewProcedure:(id)sender
{
    PEAddEditProcedureViewController *addEditProcedure = [[PEAddEditProcedureViewController alloc] initWithNibName:@"PEAddEditProcedureViewController" bundle:nil];
    addEditProcedure.navigationLabelDescription = @"Add Procedure";
    [self.navigationController pushViewController:addEditProcedure animated:YES];
}

#pragma mark - Search & UISearchDisplayDelegate

- (void)searchedResult:(NSString *)searchText scope:(NSArray *)scope
{
    NSPredicate *resultPredicat = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    if (self.specManager.isProcedureSelected) {
        self.searchResult = [[[self.specManager.currentSpecialisation.procedures allObjects] filteredArrayUsingPredicate:resultPredicat] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((Procedure *)obj1).name compare:((Procedure *)obj2).name];
        }];
    } else {
        self.searchResult = [[[self.specManager.currentSpecialisation.doctors allObjects] filteredArrayUsingPredicate:resultPredicat] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [((Doctors *)obj1).name compare:((Doctors *)obj2).name];
        }];
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    if (!searchString.length) {
        [self.tableView reloadData];
    }
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

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4B9DE1)]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    if (self.currentlySwipedAndOpenesCells.count) {
        [self.currentlySwipedAndOpenesCells removeAllObjects];
    }
}

- (void) searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
    if (self.currentlySwipedAndOpenesCells.count) {
        [self.currentlySwipedAndOpenesCells removeAllObjects];
    }
    [self.tableView reloadData];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller didLoadSearchResultsTableView:(UITableView *)tableView
{
    tableView.rowHeight = PLVCHeighForCell;
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
    UIFont *cellFont = [UIFont fontWithName:FONT_MuseoSans500 size:15.0];
    
    if (self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.procedures allObjects][indexPath.row]) {
        
        PEProcedureListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVCProcedureTableViewCellIdentifier];
        if (!cell) {
            cell = [[PEProcedureListTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PLVCProcedureTableViewCellIdentifier];
        }
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:PLVCProcedureTableViewCellIdentifier];
            cell.labelProcedureName.text = ((Procedure *)self.searchResult[indexPath.row]).name;
        } else {
            if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]) {
                [cell setCellSwiped];
            }
            cell.labelProcedureName.text = ((Procedure *)self.sortedArrayWithProcedures[indexPath.row]).name;
        }
        
        if ( indexPath.row % 2){
            cell.customContentView.backgroundColor = [UIColor whiteColor];
            cell.labelProcedureName.textColor = UIColorFromRGB(0x424242);
        } else {
            cell.customContentView.backgroundColor = UIColorFromRGB(0xE7F5FA);
            cell.labelProcedureName.textColor = UIColorFromRGB(0x499FE1);
        }
        cell.labelProcedureName.font = cellFont;
        cell.labelProcedureName.numberOfLines = 0;
        cell.delegate = self;
        returnCell = cell;
        
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentSpecialisation.doctors allObjects][indexPath.row]) {

        PEDoctorsViewTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PLVCCellName];
        if (!cell) {
            cell = [[PEDoctorsViewTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:PLVCCellName];
        }
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            cell = [self.tableView dequeueReusableCellWithIdentifier:PLVCCellName];
            cell.doctorNameLabel.text = ((Doctors *)self.searchResult[indexPath.row]).name;
        } else {
            cell.doctorNameLabel.text = ((Doctors *)self.sortedArrayWithDoctors[indexPath.row]).name;
            if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]) {
                [cell setCellSwiped];
            }
        }
        
        if ( indexPath.row % 2){
            cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
            cell.doctorNameLabel.textColor = UIColorFromRGB(0x424242);
        } else {
            cell.viewDoctorsNameView.backgroundColor = UIColorFromRGB(0xE7F5FA);
            cell.doctorNameLabel.textColor = UIColorFromRGB(0x499FE1);
        }
        
        cell.delegate = self;
        cell.doctorNameLabel.font = cellFont;
        cell.doctorNameLabel.numberOfLines = 0;
        
        returnCell = cell;
    }

    return returnCell;
}

#pragma mark - TableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.specManager.isProcedureSelected) {
        PEProcedureListTableViewCell *cell = (PEProcedureListTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell.customContentView.frame.origin.x < 0) {
            return;
        }
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
        PEDoctorsViewTableViewCell *cell = (PEDoctorsViewTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        if (cell.viewDoctorsNameView.frame.origin.x < 0) {
            return;
        }
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
    NSIndexPath *selectedCellIndexPath;
    
    if (self.isSearchTable) {
        selectedCellIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        for (Doctors *doc in [self.specManager.currentSpecialisation.doctors allObjects]) {
            if ([((Doctors *)self.searchResult[selectedCellIndexPath.row]).createdDate isEqualToDate:doc.createdDate]) {
                [self.managedObjectContext deleteObject:doc];
                NSError *delObj = nil;
                if (![self.managedObjectContext save:&delObj]) {
                    NSLog(@"Cant delete doctor");
                }
                [self refreshData];
                self.searchBar.text = self.searchBar.text; //<-- reload search result
                break;
            }
        }
    } else {
        selectedCellIndexPath = [self.tableView indexPathForCell:cell];
        for (Doctors *doc in [self.specManager.currentSpecialisation.doctors allObjects]) {
            if ([((Doctors *)self.sortedArrayWithDoctors[selectedCellIndexPath.row]).createdDate isEqualToDate:doc.createdDate]) {
                [self.managedObjectContext deleteObject:doc];
                NSError *delObj = nil;
                if (![self.managedObjectContext save:&delObj]) {
                    NSLog(@"Cant delete doctor");
                }
                [self.currentlySwipedAndOpenesCells removeObject:selectedCellIndexPath];
                [self refreshData];
                break;
            }
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

#pragma mark - PEProcedureListTableViewCellGestrudeDelegate

- (void)buttonDeleteActionProcedure:(UITableViewCell *)cell
{
    NSIndexPath *indexPathToDelete;
    if (self.isSearchTable){
        indexPathToDelete = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        
        for (Procedure *proc in [self.specManager.currentSpecialisation.procedures allObjects]) {
            if ([proc.procedureID isEqualToString:((Procedure *)self.searchResult[indexPathToDelete.row]).procedureID]){
                [self.managedObjectContext deleteObject:proc];
                break;
            }
        }
        
        for (Procedure *procedure in [self.specManager.currentSpecialisation.procedures allObjects]) {
            if ([self getNSIntegerProcedureIdFromStringID:procedure.procedureID] > [self getNSIntegerProcedureIdFromStringID:((Procedure *)self.searchResult[indexPathToDelete.row]).procedureID]) {
                
                NSInteger newIndex = [self getNSIntegerProcedureIdFromStringID:procedure.procedureID] - 1;
                procedure.procedureID = [self createUpdatedProcedureId:newIndex];
            }
        }
    } else {
        indexPathToDelete = [self.tableView indexPathForCell:cell];
        
        for (Procedure *proc in [self.specManager.currentSpecialisation.procedures allObjects]) {
            if ([proc.procedureID isEqualToString:((Procedure *)self.sortedArrayWithProcedures[indexPathToDelete.row]).procedureID]){
                [self.managedObjectContext deleteObject:proc];
                break;
            }
        }
        
        for (Procedure *procedure in [self.specManager.currentSpecialisation.procedures allObjects]) {
            if ([self getNSIntegerProcedureIdFromStringID:procedure.procedureID] > [self getNSIntegerProcedureIdFromStringID:((Procedure *)self.sortedArrayWithProcedures[indexPathToDelete.row]).procedureID]) {
                
                NSInteger newIndex = [self getNSIntegerProcedureIdFromStringID:procedure.procedureID] - 1;
                procedure.procedureID = [self createUpdatedProcedureId:newIndex];
            }
        }
        [self.currentlySwipedAndOpenesCells removeAllObjects];
    }
    
    [self saveChangesToLocalDataBase:@"searchProcedure"];
    ((PEProcedureListTableViewCell *)cell).deleteButton.hidden = YES;
    [self refreshData];
}

- (void)cellDidSwipedInProcedure:(UITableViewCell *)cell
{
    if (!self.isSearchTable)  {
        [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
    }
}

- (void)cellDidSwipedOutProcedure:(UITableViewCell *)cell
{
    if (!self.isSearchTable) {
        NSIndexPath *currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
        if (!self.currentlySwipedAndOpenesCells) {
            self.currentlySwipedAndOpenesCells = [[NSMutableSet alloc] init];
        }
        [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
    }
}

- (void)longPressRecognised:(UITableViewCell *)cell
{
    NSIndexPath * selectedProcIndexPath;
    if (self.isSearchTable) {
        selectedProcIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForCell:cell];
        self.specManager.currentProcedure = self.searchResult[selectedProcIndexPath.row];
    } else {
        selectedProcIndexPath = [self.tableView indexPathForCell:cell];
        self.specManager.currentProcedure = self.sortedArrayWithProcedures[selectedProcIndexPath.row];
    }
    PEAddEditProcedureViewController *controller = [[PEAddEditProcedureViewController alloc] initWithNibName:@"PEAddEditProcedureViewController" bundle:nil];
    controller.navigationLabelDescription = @"Edit Procedure Name";
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Private

- (NSString *)createUpdatedProcedureId:(NSInteger)newIndex
{
    NSString *newProcedureIDString;
    if ([NSString stringWithFormat:@"%i", (int)newIndex].length == 3) {
        newProcedureIDString = [NSString stringWithFormat:@"S0%i", (int)newIndex];
    } else {
        newProcedureIDString = [NSString stringWithFormat:@"S%i", (int)newIndex];
    }
    return newProcedureIDString;
}

- (NSInteger)getNSIntegerProcedureIdFromStringID:(NSString *)procedureID
{
    NSInteger procedureIDInt;
    if ([procedureID hasPrefix:@"S"] && procedureID.length) {
        procedureIDInt = [[procedureID substringFromIndex:1] integerValue];
    }
    return procedureIDInt;
}

- (void)saveChangesToLocalDataBase:(NSString *)description
{
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant delete %@ - %@",description, error.localizedDescription);
    }
}

- (void)refreshData
{
    self.sortedArrayWithProcedures = [self sortedArrayWitProcedures:[self.specManager.currentSpecialisation.procedures allObjects]];
    self.sortedArrayWithDoctors = [self sortedArrayWitDoctors:[self.specManager.currentSpecialisation.doctors allObjects]];
    if (self.isSearchTable) {
        [self.searchBar setText:self.searchBar.text];
        [self.searchDisplayController.searchResultsTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    }
}

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
