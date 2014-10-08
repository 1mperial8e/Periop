//
//  PEDoctorsListViewController.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const DLCellName = @"doctorsCell";
static NSString *const DLNibName = @"PEDoctorsViewTableViewCell";

#import "PEDoctorsListViewController.h"
#import "PEDoctorsViewTableViewCell.h"
#import "PEAddEditDoctorViewController.h"
#import "PEMenuViewController.h"
#import "PEObjectDescription.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "Doctors.h"
#import "UIImage+fixOrientation.h"
#import "UIImage+ImageWithJPGFile.h"

@interface PEDoctorsListViewController () <UITableViewDataSource, UITableViewDelegate , PEDoctorsViewTableViewCellDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) UIBarButtonItem *navigationBarAddBarButton;
@property (strong, nonatomic) UIBarButtonItem *navigationBarMenuButton;
@property (strong, nonatomic) NSMutableSet *currentlySwipedAndOpenesCells;
@property (strong, nonatomic) NSMutableArray *arrayWithAllDocators;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSArray *searchResult;
@property (assign, nonatomic) BOOL isSearchTable;

@end

@implementation PEDoctorsListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.isSearchTable = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeBottom;
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    [self.tableView registerNib:[UINib nibWithNibName:DLNibName bundle:nil] forCellReuseIdentifier:DLCellName];

    UIBarButtonItem * addDoctorButton = [[UIBarButtonItem alloc] initWithImage:[UIImage  imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addDoctorButton:)];

    self.navigationBarAddBarButton = addDoctorButton;

    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.currentlySwipedAndOpenesCells = [NSMutableSet new];
    self.arrayWithAllDocators = [[NSMutableArray alloc] init];
    [self customizingSearchBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    NSString *textForHeader;
    if (self.textToShow && self.textToShow.length){
        textForHeader = self.textToShow;
    } else {
        textForHeader = @"Surgeon List";
    }
    ((PENavigationController *)self.navigationController).titleLabel.text = textForHeader;
    
    self.navigationItem.rightBarButtonItem = self.navigationBarAddBarButton;
    if (self.isButtonRequired) {
        self.navigationItem.leftBarButtonItem = self.navigationBarMenuButton;
    }
    [self initWithData];
    [self.tableView reloadData];
}

#pragma mark - Search & UISearchDisplayDelegate

- (void)searchedResult:(NSString *)searchText scope:(NSArray *)scope
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

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4B9DE1)]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchDisplayController.searchBar setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor]]
                                                forBarPosition:0
                                                    barMetrics:UIBarMetricsDefault];
}

- (void)customizingSearchBar
{
    [self.searchBar setBackgroundImage:[[UIImage alloc] init]];
    
    [self.searchBar setImage:[UIImage imageNamedFile:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateHighlighted];
    [self.searchBar setImage:[UIImage imageNamedFile:@"Cancel_Search"] forSearchBarIcon:UISearchBarIconClear state:UIControlStateNormal];
    
    NSArray *searchBarSubViews = [[self.searchBar.subviews objectAtIndex:0] subviews];
    for(int i = 0; i < searchBarSubViews.count; i++) {
        if([[searchBarSubViews objectAtIndex:i] isKindOfClass:[UITextField class]]) {
            UITextField *search = (UITextField *)[searchBarSubViews objectAtIndex:i];
            [search setFont:[UIFont fontWithName:FONT_MuseoSans500 size:12.5]];
            [search setTintColor:UIColorFromRGB(0x4D4D4D)];
            search.placeholder = @"Search";
            search.backgroundColor = [UIColor whiteColor];
            search.layer.borderColor = UIColorFromRGB(0x4B9DE1).CGColor;
            search.layer.borderWidth = 1.0f;
            search.layer.cornerRadius = 8.0f;
            search.alpha = 1.0f;
            search.leftViewMode = UITextFieldViewModeNever;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return self.searchResult.count;
    }
    return self.arrayWithAllDocators.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEDoctorsViewTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:DLCellName forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorsViewTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:DLCellName];
    }
    if (indexPath.row % 2) {
        cell.viewDoctorsNameView.backgroundColor = UIColorFromRGB(0xE7F5FA);
        cell.doctorNameLabel.textColor = UIColorFromRGB(0x499FE1);
    } else {
        cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
        cell.doctorNameLabel.textColor = UIColorFromRGB(0x424242);
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

#pragma mark - IBActions

- (IBAction)addDoctorButton:(id)sender
{
    PEAddEditDoctorViewController *addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    addEditDoctorView.isEditedDoctor = NO;
    [self.navigationController pushViewController:addEditDoctorView animated:YES];
}

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = @"Surgeon List";
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
#ifdef __IPHONE_8_0
    menuController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

#pragma mark - PEDoctorsViewTableViewCellDelegate

- (void)cellDidSwipedOut:(UITableViewCell *)cell
{
    if (!self.isSearchTable) {
        NSIndexPath *currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
        [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
    }
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    if (!self.isSearchTable)  {
        [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
    }
}

- (void)buttonDeleteAction:(UITableViewCell *)cell
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (self.isSearchTable)  {
        [self.managedObjectContext deleteObject:((Doctors *)self.searchResult[indexPath.row])];
        [self initWithData];
        [self.tableView reloadData];
        [self.searchDisplayController.searchResultsTableView reloadData];
        self.searchBar.text = self.searchBar.text;
    } else {
        NSLog(@"delete action");
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        [self.managedObjectContext deleteObject:(Doctors *)(self.arrayWithAllDocators[indexPath.row])];
        [self.currentlySwipedAndOpenesCells removeObject:indexPath];
        [self.arrayWithAllDocators removeObject:(Doctors *)(self.arrayWithAllDocators[indexPath.row])];
        [self.tableView reloadData];
    }
    NSError *deleteError = nil;
    if (![self.managedObjectContext save:&deleteError]) {
        NSLog(@"Cant remove doctor - %@", deleteError.localizedDescription);
    }
}

#pragma mark - Private

- (void)initWithData
{
    PEObjectDescription *objectToSearch = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Doctors" withSortDescriptorKey:@"name"];
    
    if (self.specManager.currentProcedure.name) {
        NSArray *allDoctorsArray = [NSMutableArray arrayWithArray:[PECoreDataManager getAllEntities:objectToSearch]];
        NSMutableArray *requiredDoctors = [[NSMutableArray alloc] init];
        for (Doctors *doctor in allDoctorsArray) {
            for (Procedure *proceduresOfDoctor in [doctor.procedure allObjects]){
                if ([proceduresOfDoctor.procedureID isEqualToString:self.specManager.currentProcedure.procedureID]) {
                    if (![requiredDoctors containsObject:doctor]) {
                        [requiredDoctors addObject:doctor];
                    }
                }
            }
        }
        NSArray *sorted = [requiredDoctors sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *name1 = [(Doctors*)obj1 name];
            NSString *name2 = [(Doctors*)obj2 name];
            return [name1 compare:name2];
        }];
        self.arrayWithAllDocators= [sorted mutableCopy];
    } else {
        NSArray *sorted = [[PECoreDataManager getAllEntities:objectToSearch] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *name1 = [(Doctors*)obj1 name];
            NSString *name2 = [(Doctors*)obj2 name];
            return [name1 compare:name2];
        }];
        self.arrayWithAllDocators = [sorted mutableCopy];
    }
}

@end
