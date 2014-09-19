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
@property (strong, nonatomic) NSMutableArray * arrayWithCategorisedToolsArrays;
@property (strong, nonatomic) NSMutableArray * categoryTools;
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
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
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
    return self.categoryTools.count;
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

- (void)buttonDeleteAction:(UITableViewCell*)cell
{
    NSIndexPath * currentIndex = [self.tableView indexPathForCell:cell];
    EquipmentsTool *eq = ((EquipmentsTool*)((NSArray*)self.arrayWithCategorisedToolsArrays[currentIndex.section])[currentIndex.row]);
    [self.specManager.currentProcedure removeEquipmentsObject:eq];
    NSError * deleteError = nil;
    if (![self.managedObjectContext save:&deleteError]) {
        NSLog(@"Cant delete object - %@", deleteError.localizedDescription);
    } else {
        NSLog(@"Delete success for relationShip");
        [self.managedObjectContext deleteObject:eq];
        NSLog(@"Delete success from DB");
    }
    
    [self.cellCurrentlyEditing removeObject:currentIndex];
    [self.cellWithCheckedButtons removeObject:currentIndex];

    NSArray * currentArray = self.arrayWithCategorisedToolsArrays[currentIndex.section];
  //  [ removeObject:eq];
    [self.categoryTools removeObjectAtIndex:currentIndex.section];
    NSInteger  sectionArray = [self.arrayWithCategorisedToolsArrays[currentIndex.section] count];
    if ( sectionArray== 0){
//        [self.arrayWithCategorisedToolsArrays removeObject:self.arrayWithCategorisedToolsArrays[currentIndex.section]];
    }
    
        [self.tableView reloadData];
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

- (NSMutableArray*)sortArrayByCategoryAttribute: (NSArray*)objectsArray
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

- (NSMutableArray* )categoryType: (NSArray*)objectsArray
{
    NSCountedSet * toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    return [NSMutableArray arrayWithArray:[toolsWithCounts allObjects]];
}
@end
