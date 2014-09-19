//
//  PEEquipmentViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEquipmentViewController.h"
#import "PEEquipmentCategoryTableViewCell.h"
#import "PEToolsDetailsViewController.h"
#import "PEAddNewToolViewController.h"

#import "EquipmentsTool.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"

@interface PEEquipmentViewController () <UITableViewDataSource, UITableViewDelegate, PEEquipmentCategoryTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addNewButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) NSMutableSet *cellCurrentlyEditing;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSArray * arrayWithCategorisedToolsArrays;
@property (strong, nonatomic) NSArray * categoryTools;
@property (strong, nonatomic) NSMutableSet * cellWithCheckedButtons;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end

@implementation PEEquipmentViewController

#pragma mark - LifeCycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.arrayWithCategorisedToolsArrays = [self sortArrayByCategoryAttribute:[self.specManager.currentProcedure.equipments allObjects]];
    self.categoryTools = [self categoryType:[self.specManager.currentProcedure.equipments allObjects]];

    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.text = ((Procedure*)self.specManager.currentProcedure).name;
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAll:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEquipmentCategoryTableViewCell" bundle:nil] forCellReuseIdentifier:@"equipmentCell"];
    self.cellCurrentlyEditing = [NSMutableSet new];
    self.cellWithCheckedButtons = [NSMutableSet new];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super   viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)addNewButton:(id)sender
{
    PEAddNewToolViewController * addNewTool = [[PEAddNewToolViewController alloc] initWithNibName:@"PEAddNewToolViewController" bundle:nil];
    [self.navigationController pushViewController:addNewTool animated:NO];
}

- (IBAction)eMailButton:(id)sender
{
    
}

- (IBAction)clearAll:(id)sender
{
    
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return ((NSArray*)self.arrayWithCategorisedToolsArrays[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEEquipmentCategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentCell" forIndexPath:indexPath];
    if (!cell){
        cell = [[PEEquipmentCategoryTableViewCell alloc] init];
    }

    cell.equipmentNameLabel.text = ((EquipmentsTool*)((NSArray*)self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).name;
    
    cell.delegate = self;
    if ([self.cellCurrentlyEditing containsObject:indexPath]) {
        [cell setCellSwiped];
    }
    if ([self.cellWithCheckedButtons containsObject:indexPath]) {
         [cell cellSetChecked];
    }

    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arrayWithCategorisedToolsArrays.count;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return (NSString*)self.categoryTools[section];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.specManager.currentEquipment = ((EquipmentsTool*)((NSArray*)self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]);
    
    PEToolsDetailsViewController * toolDetailsView = [[PEToolsDetailsViewController alloc] initWithNibName:@"PEToolsDetailsViewController" bundle:nil];
    [self.navigationController pushViewController:toolDetailsView animated:NO];
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate

- (void)buttonDeleteAction
{
    NSLog(@"inside button action from delegate PEEquipmentCategoryTableViewCellDelegate");
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    [self.cellCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)cellDidSwipedOut:(UITableViewCell *)cell{
    NSIndexPath * currentlyEditedIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellCurrentlyEditing addObject:currentlyEditedIndexPath];
}

- (void)cellChecked:(UITableViewCell *)cell
{
    NSIndexPath * currentlyEditedIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellWithCheckedButtons addObject:currentlyEditedIndexPath];
}

- (void)cellUnchecked:(UITableViewCell *)cell
{
    [self.cellWithCheckedButtons removeObject:[self.tableView indexPathForCell:cell]];
}

#pragma mark - Private

- (NSArray*)sortArrayByCategoryAttribute: (NSArray*)objectsArray
{
    NSMutableArray * arrayWithCategorisedArrays =[[NSMutableArray alloc] init];
    NSCountedSet * toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    NSArray * uniqueCategory = [toolsWithCounts allObjects];
    
    for (int i=0; i< uniqueCategory.count; i++){
        NSMutableArray * categoryArray = [[NSMutableArray alloc] init];
        for (EquipmentsTool * equipment in objectsArray) {
            if ([equipment.category isEqualToString:[NSString stringWithFormat:@"%@", uniqueCategory[i]] ]) {
                [categoryArray addObject:equipment];
            }
        }
        [arrayWithCategorisedArrays addObject:categoryArray];
    }
    return arrayWithCategorisedArrays;
}

- (NSArray* )categoryType: (NSArray*)objectsArray
{
    NSCountedSet * toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    return [toolsWithCounts allObjects];
}

@end
