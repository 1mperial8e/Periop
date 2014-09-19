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

@interface PEDoctorsListViewController () <UITableViewDataSource, UITableViewDelegate , PEDoctorsViewTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UIBarButtonItem * navigationBarAddBarButton;
@property (strong, nonatomic) UIBarButtonItem * navigationBarMenuButton;
@property (strong, nonatomic) UILabel * labelToShowOnNavigationBar;
@property (strong, nonatomic) NSMutableSet * currentlySwipedAndOpenesCells;

@end

@implementation PEDoctorsListViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.labelToShowOnNavigationBar = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.labelToShowOnNavigationBar.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.labelToShowOnNavigationBar.minimumScaleFactor = 0.5;
    self.labelToShowOnNavigationBar.adjustsFontSizeToFitWidth = YES;
    self.labelToShowOnNavigationBar.backgroundColor = [UIColor clearColor];
    self.labelToShowOnNavigationBar.textColor = [UIColor whiteColor];
    self.labelToShowOnNavigationBar.textAlignment = NSTextAlignmentCenter;
    if (self.textToShow && self.textToShow.length!=0){
        self.labelToShowOnNavigationBar.text = self.textToShow;
    } else {
        self.labelToShowOnNavigationBar.text = @"Surgeon List";
    }
    
    UIBarButtonItem * addDoctorButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDoctorButton:)];
    self.navigationBarAddBarButton = addDoctorButton;

    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.searchBar.tintColor = [UIColor whiteColor];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsViewTableViewCell" bundle:nil]  forCellReuseIdentifier:@"doctorsCell"];
    
    self.currentlySwipedAndOpenesCells = [NSMutableSet new];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.labelToShowOnNavigationBar];
    self.navigationItem.rightBarButtonItem = self.navigationBarAddBarButton;
    if (self.isButtonRequired) {
        self.navigationItem.leftBarButtonItem = self.navigationBarMenuButton;
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.labelToShowOnNavigationBar removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 25;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PEDoctorsViewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"doctorsCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEDoctorsViewTableViewCell alloc] init];
    }
    cell.delegate = self;
    if ( indexPath.row % 2) {
        cell.viewDoctorsNameView.backgroundColor = [UIColor colorWithRed:236/255.0 green:248/255.0 blue:251/255.0 alpha:1.0f];
    } else {
        cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
    }
    if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]) {
        [cell setCellSwiped];
    }
    cell.doctorNameLabel.text = [NSString stringWithFormat:@"Doctor number %i", (int)[indexPath row]];
    return cell;
}

#pragma mark - IBActions

- (IBAction)addDoctorButton:(id)sender
{
    PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
    addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
    [self.navigationController pushViewController:addEditDoctorView animated:NO];
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
    NSIndexPath * currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
    [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)buttonDeleteAction
{
    NSLog(@"delete action");
}

@end
