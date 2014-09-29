//
//  PEDoctorsListViewController.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDoctorsListViewController.h"
#import "PEDoctorsViewTableViewCell.h"
#import "PEAddEditDoctorViewController.h"
#import "PEMenuViewController.h"
#import "PEObjectDescription.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "Doctors.h"

@interface PEDoctorsListViewController () <UITableViewDataSource, UITableViewDelegate , PEDoctorsViewTableViewCellDelegate, UISearchDisplayDelegate>


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UIBarButtonItem * navigationBarAddBarButton;
@property (strong, nonatomic) UIBarButtonItem * navigationBarMenuButton;
@property (strong, nonatomic) UILabel * labelToShowOnNavigationBar;
@property (strong, nonatomic) NSMutableSet * currentlySwipedAndOpenesCells;
@property (strong, nonatomic) NSMutableArray * arrayWithAllDocators;
@property (strong, nonatomic) NSManagedObjectContext* managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSArray *searchResult;
@property (assign, nonatomic) BOOL isSearchTable;

@end

@implementation PEDoctorsListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isSearchTable = NO;
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsViewTableViewCell" bundle:nil]  forCellReuseIdentifier:@"doctorsCell"];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.labelToShowOnNavigationBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.labelToShowOnNavigationBar.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.labelToShowOnNavigationBar.minimumScaleFactor = 0.5;
    self.labelToShowOnNavigationBar.adjustsFontSizeToFitWidth = YES;
    self.labelToShowOnNavigationBar.backgroundColor = [UIColor clearColor];
    self.labelToShowOnNavigationBar.textColor = [UIColor whiteColor];
    self.labelToShowOnNavigationBar.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.labelToShowOnNavigationBar.textAlignment = NSTextAlignmentCenter;
    self.labelToShowOnNavigationBar.numberOfLines = 0;
    if (self.textToShow && self.textToShow.length!=0){
        self.labelToShowOnNavigationBar.text = self.textToShow;
    } else {
        self.labelToShowOnNavigationBar.text = @"Surgeon List";
    }
    
    UIBarButtonItem * addDoctorButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDoctorButton:)];
    self.navigationBarAddBarButton = addDoctorButton;

    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.currentlySwipedAndOpenesCells = [NSMutableSet new];
    self.arrayWithAllDocators = [[NSMutableArray alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.labelToShowOnNavigationBar];
    self.navigationItem.rightBarButtonItem = self.navigationBarAddBarButton;
    if (self.isButtonRequired) {
        self.navigationItem.leftBarButtonItem = self.navigationBarMenuButton;
    }
    [self initWithData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.labelToShowOnNavigationBar removeFromSuperview];
}

#pragma mark - Search & UISearchDisplayDelegate

- (void)searchedResult: (NSString*)searchText scope:(NSArray*)scope
{
    NSPredicate *resultPredicat = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
        self.searchResult = [self.arrayWithAllDocators filteredArrayUsingPredicate:resultPredicat];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self searchedResult:searchString scope:[[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willShowSearchResultsTableView:(UITableView *)tableView{
    [self.searchDisplayController.searchResultsTableView setSeparatorColor:[UIColor clearColor]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResult.count;
    } else {
        return self.arrayWithAllDocators.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEDoctorsViewTableViewCell * cell = [self.tableView dequeueReusableCellWithIdentifier:@"doctorsCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorsViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"doctorsCell"];
    }
    
    if ( indexPath.row % 2){
        cell.viewDoctorsNameView.backgroundColor = [UIColor colorWithRed:(231.0/255.0) green:(245.0/255.0) blue:(250.0/255.0) alpha:1.0f];
        cell.doctorNameLabel.textColor = [UIColor colorWithRed:(73.0/255.0) green:(159.0/255.0) blue:(225.0/255.0) alpha:1.0f];
    } else {
        cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
        cell.doctorNameLabel.textColor = [UIColor colorWithRed:(66.0/255.0) green:(66.0/255.0) blue:(66.0/255.0) alpha:1.0f];
    }
    cell.delegate = self;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.isSearchTable = YES;
        cell.doctorNameLabel.text = ((Doctors*)self.searchResult[indexPath.row]).name;
    } else {
        self.isSearchTable = NO;
        if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]) {
            [cell setCellSwiped];
        }
        cell.doctorNameLabel.text = ((Doctors*)(self.arrayWithAllDocators[indexPath.row])).name;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 46;
}

#pragma mark - IBActions

- (IBAction)addDoctorButton:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    addEditDoctorView.isEditedDoctor = NO;
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.sizeOfFontInNavLabel = self.labelToShowOnNavigationBar.font.pointSize;
    menuController.textToShow = @"Surgeon List";
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

#pragma mark - PEDoctorsViewTableViewCellDelegate

- (void)cellDidSwipedOut:(UITableViewCell *)cell
{
    if (!self.isSearchTable) {
        NSIndexPath * currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
        [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
    }
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    if (!self.isSearchTable)  {
        [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
    }
}

- (void)buttonDeleteAction:(UITableViewCell*)cell
{
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    
    if (self.isSearchTable)  {
        [self.managedObjectContext deleteObject:((Doctors*)self.searchResult[indexPath.row])];
        [self initWithData];
        [self.tableView reloadData];
        [self.searchDisplayController.searchResultsTableView reloadData];
        self.searchBar.text = self.searchBar.text;
    } else {
        NSLog(@"delete action");
        NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
        [self.managedObjectContext deleteObject:(Doctors*)(self.arrayWithAllDocators[indexPath.row])];
        [self.currentlySwipedAndOpenesCells removeObject:indexPath];
        [self.arrayWithAllDocators removeObject:(Doctors*)(self.arrayWithAllDocators[indexPath.row])];
        [self.tableView reloadData];
    }
    
    NSError * deleteError = nil;
    if (![self.managedObjectContext save:&deleteError]) {
        NSLog(@"Cant remove doctor - %@", deleteError.localizedDescription);
    }
}

#pragma mark - Private

- (void) initWithData
{
    PEObjectDescription * objectToSearch = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Doctors" withSortDescriptorKey:@"name"];
    
    if (self.specManager.currentProcedure.name!=nil) {
        NSArray * allDoctorsArray = [NSMutableArray arrayWithArray:[PECoreDataManager getAllEntities:objectToSearch]];
        NSMutableArray * requiredDoctors = [[NSMutableArray alloc] init];
        for (Doctors * doctor in allDoctorsArray) {
            for (Procedure * proceduresOfDoctor in [doctor.procedure allObjects]){
                if ([proceduresOfDoctor.procedureID isEqualToString:self.specManager.currentProcedure.procedureID]) {
                    if (![requiredDoctors containsObject:doctor]) {
                        [requiredDoctors addObject:doctor];
                    }
                }
            }
        }
        NSArray * sorted = [requiredDoctors sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString * name1 = [(Doctors*)obj1 name];
            NSString * name2 = [(Doctors*)obj2 name];
            return [name1 compare:name2];
        }];
        self.arrayWithAllDocators= [sorted mutableCopy];
    } else {
        NSArray * sorted = [[PECoreDataManager getAllEntities:objectToSearch] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString * name1 = [(Doctors*)obj1 name];
            NSString * name2 = [(Doctors*)obj2 name];
            return [name1 compare:name2];
        }];
        self.arrayWithAllDocators = [sorted mutableCopy];
    }
}

@end
