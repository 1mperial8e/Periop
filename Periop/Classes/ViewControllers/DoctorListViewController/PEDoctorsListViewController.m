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

@property (strong, nonatomic) UIBarButtonItem * navigationBarAddBarButton;
@property (strong, nonatomic) UIBarButtonItem * navigationBarMenuButton;
@property (strong, nonatomic) UILabel * labelToShowOnNavigationBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

//place to store set of opened cells
@property (strong, nonatomic) NSMutableSet * currentlySwipedAndOpenesCells;

@end

@implementation PEDoctorsListViewController

#pragma mark - LifeCycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //add label
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    navigationLabel.text = self.textToShow;
    self.labelToShowOnNavigationBar = navigationLabel;
    
    //create button for menu
    UIBarButtonItem * addDoctorButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDoctorButton:)];
    self.navigationBarAddBarButton = addDoctorButton;
    //create button for menu
    UIImage *buttonImage = [UIImage imageNamed:@"Menu"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem * menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:self action:@selector(menuButton:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationBarMenuButton = menuBarButton;
    
    //navigation backButton
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.searchBar.tintColor = [UIColor whiteColor];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEDoctorsViewTableViewCell" bundle:nil]  forCellReuseIdentifier:@"doctorsCell"];
    
    //init mutableSet
    self.currentlySwipedAndOpenesCells = [NSMutableSet new];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.labelToShowOnNavigationBar];
    self.navigationItem.rightBarButtonItem = self.navigationBarAddBarButton;
    if (self.isButtonRequired){
        self.navigationItem.leftBarButtonItem = self.navigationBarMenuButton;
    }
}

- (void) viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.labelToShowOnNavigationBar removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 25;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PEDoctorsViewTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"doctorsCell" forIndexPath:indexPath];
    if (!cell){
        cell = [[PEDoctorsViewTableViewCell alloc] init];
    }
    //set delegate to cell
    cell.delegate = self;
    if ( indexPath.row % 2){
        cell.viewDoctorsNameView.backgroundColor = [UIColor colorWithRed:236/255.0 green:248/255.0 blue:251/255.0 alpha:1.0f];
    }
    else {
        cell.viewDoctorsNameView.backgroundColor = [UIColor whiteColor];
    }
    if ([self.currentlySwipedAndOpenesCells containsObject:indexPath]){
        [cell setCellSwiped];
    }
    cell.doctorNameLabel.text = [NSString stringWithFormat:@"Doctor number %d", [indexPath row]];
    return cell;
}

#pragma mark - IBActions

- (IBAction)addDoctorButton:(id)sender{
    if ([self.tableView indexPathForSelectedRow]){
        PEAddEditDoctorViewController * addEditDoctorView = [[PEAddEditDoctorViewController alloc] initWithNibName:@"PEAddEditDoctorViewController" bundle:nil];
        addEditDoctorView.navigationLabelDescription = @"Add Surgeon";
        [self.navigationController pushViewController:addEditDoctorView animated:NO];
    }
}

- (IBAction)menuButton:(id)sender{
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.navController = self.navigationController;
    menuController.sizeOfFontInNavLabel = self.labelToShowOnNavigationBar.font.pointSize;
    menuController.textToShow = @"Surgeon List";
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
    [self presentViewController:menuController animated:NO completion:nil];
}

#pragma mark - PEDoctorsViewTableViewCellDelegate

- (void)cellDidSwipedOut:(UITableViewCell *)cell{
    NSIndexPath * currentOpenedCellIndexPath = [self.tableView indexPathForCell:cell];
    [self.currentlySwipedAndOpenesCells addObject:currentOpenedCellIndexPath];
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell{
    [self.currentlySwipedAndOpenesCells removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)buttonDeleteAction {
    NSLog(@"delete action");
}


@end
