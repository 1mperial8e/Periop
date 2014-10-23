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
#import "UIImage+fixOrientation.h"
#import "EquipmentsTool.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import <MessageUI/MessageUI.h>

static NSString *const EEquipmentCellIdentifier = @"equipmentCell";
static CGFloat const EHeightForHeader = 36.5f;
static CGFloat const EMinimumHeightOfCell = 47.0f;

@interface PEEquipmentViewController () <UITableViewDataSource, UITableViewDelegate, PEEquipmentCategoryTableViewCellDelegate, MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *addNewButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@property (strong, nonatomic) NSMutableSet *cellCurrentlyEditing;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSMutableArray *arrayWithCategorisedToolsArrays;
@property (strong, nonatomic) NSMutableArray *categoryTools;
@property (strong, nonatomic) NSMutableSet *cellWithCheckedButtons;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) MFMailComposeViewController *mailController;

@end

@implementation PEEquipmentViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView reloadData];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAll:)];
    [closeButton setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:FONT_MuseoSans300 size:13.5f]} forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = closeButton;
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEquipmentCategoryTableViewCell" bundle:nil] forCellReuseIdentifier:EEquipmentCellIdentifier];
    self.cellCurrentlyEditing = [NSMutableSet new];
    self.cellWithCheckedButtons = [NSMutableSet new];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = ((Procedure*)self.specManager.currentProcedure).name;
    
    self.arrayWithCategorisedToolsArrays = [self sortArrayByCategoryAttribute:[self.specManager.currentProcedure.equipments allObjects]];
    self.categoryTools = [self categoryType:[self.specManager.currentProcedure.equipments allObjects]];

    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.cellWithCheckedButtons  removeAllObjects];
    [self.cellCurrentlyEditing removeAllObjects];
}

#pragma mark - IBActions

- (IBAction)addNewButton:(id)sender
{
    PEAddNewToolViewController *addNewTool = [[PEAddNewToolViewController alloc] initWithNibName:@"PEAddNewToolViewController" bundle:nil];
    [self.navigationController pushViewController:addNewTool animated:YES];
}

- (IBAction)clearAll:(id)sender
{
    if (self.cellWithCheckedButtons) {
        [self.cellWithCheckedButtons removeAllObjects];
        [self.tableView reloadData];
    }
}

- (IBAction)eMailButton:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x4B9DE1)];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:UIColorFromRGB(0x4B9DE1)] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:                                                               
                                                              [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
        
        self.mailController = [[MFMailComposeViewController alloc] init];
        self.mailController.mailComposeDelegate = self;
        
        [self.mailController setSubject:@"Equipment list"];
        
        [self.mailController setMessageBody:[self getMessageBody] isHTML:YES];
        UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        rootController.modalPresentationStyle = UIModalPresentationFullScreen;
#ifdef __IPHONE_8_0
        self.mailController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
        [self presentViewController:self.mailController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }];
    } else {
        UIAlertView *alerMail = [[UIAlertView alloc] initWithTitle:@"No mail accounts" message:@"Please setup your e-mail account through device settings." delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
        [alerMail show];
    }
}

#pragma mark - MailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result) {
        switch (result) {
            case MFMailComposeResultSent:
                NSLog(@"You sent the email.");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"You saved a draft of this email");
                break;
            case MFMailComposeResultCancelled:
                NSLog(@"You cancelled sending this email.");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"Mail failed:  An error occurred when trying to compose this email");
                break;
            default:
                NSLog(@"An error occurred when trying to compose this email");
                break;
        }
    }
    if (error) {
        NSLog(@"Error to send mail - %@", error.localizedDescription);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
   return ((NSArray *)self.arrayWithCategorisedToolsArrays[section]).count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEEquipmentCategoryTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EEquipmentCellIdentifier forIndexPath:indexPath];
    if (!cell){
        cell = [[PEEquipmentCategoryTableViewCell alloc] init];
    }
    cell = [self configureCell:cell atIndexPath:indexPath];
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
    return (NSString *)self.categoryTools[section];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *myLabel = [[UILabel alloc] init];
    myLabel.frame = CGRectMake(16.5f, 0, self.view.frame.size.width - 16.5f, EHeightForHeader);
    myLabel.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    myLabel.textColor = UIColorFromRGB(0x4B9DE1);
    myLabel.backgroundColor = [UIColor whiteColor];
    myLabel.text = [self tableView:tableView titleForHeaderInSection:section];
    
    UIView *separatorView = [[UIView alloc] initWithFrame:CGRectMake(0, EHeightForHeader - 1, self.view.bounds.size.width, 1)];
    separatorView.backgroundColor = UIColorFromRGB(0xDBDBDB);
    
    UIView *headerView = [[UIView alloc] init];
    [headerView addSubview:myLabel];
    [headerView addSubview:separatorView];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEEquipmentCategoryTableViewCell *cell = (PEEquipmentCategoryTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.viewWithContent.frame.origin.x < 0) {
        return;
    }
    
    self.specManager.currentEquipment = ((EquipmentsTool*)((NSArray*)self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]);
    
    PEToolsDetailsViewController *toolDetailsView = [[PEToolsDetailsViewController alloc] initWithNibName:@"PEToolsDetailsViewController" bundle:nil];
    [self.navigationController pushViewController:toolDetailsView animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return EHeightForHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self heightForBasicCellAtIndexPath:indexPath] < EMinimumHeightOfCell) {
        return EMinimumHeightOfCell;
    } else {
        return [self heightForBasicCellAtIndexPath:indexPath];
    }
}

#pragma mark - DynamicHeightOfCell

- (PEEquipmentCategoryTableViewCell *)configureCell:(PEEquipmentCategoryTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSMutableString *titleForEquipmentCell = [[NSMutableString alloc] init];
    [titleForEquipmentCell appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).name];
    if (![((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).type isEqualToString:@""]) {
        [titleForEquipmentCell appendString:@", "];
        [titleForEquipmentCell appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).type];
    }
    if (![((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).quantity isEqualToString:@""]) {
        [titleForEquipmentCell appendString:@", "];
        [titleForEquipmentCell appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexPath.section])[indexPath.row]).quantity];
    }
    cell.equipmentNameLabel.text = titleForEquipmentCell;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *) indexPath
{
    static PEEquipmentCategoryTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:EEquipmentCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate

- (void)buttonDeleteAction:(UITableViewCell *)cell
{
    NSIndexPath *currentIndex = [self.tableView indexPathForCell:cell];
    [self deleteSelectedItem:currentIndex];
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell
{
    [self.cellCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)cellDidSwipedOut:(UITableViewCell *)cell{
    NSIndexPath *currentlyEditedIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellCurrentlyEditing addObject:currentlyEditedIndexPath];
}

- (void)cellChecked:(UITableViewCell *)cell
{
    NSIndexPath *currentlyEditedIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellWithCheckedButtons addObject:currentlyEditedIndexPath];
}

- (void)cellUnchecked:(UITableViewCell *)cell
{
    [self.cellWithCheckedButtons removeObject:[self.tableView indexPathForCell:cell]];
}

#pragma mark - Private

- (NSMutableArray *)sortArrayByCategoryAttribute:(NSArray *)objectsArray
{
    NSMutableArray *arrayWithCategorisedArrays =[[NSMutableArray alloc] init];
    NSCountedSet *toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    NSArray *uniqueCategory = [[toolsWithCounts allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *categotyOne = (NSString *)obj1;
        NSString *categotyTwo = (NSString *)obj2;
        return [categotyOne compare:categotyTwo];
    }];
    
    for (int i = 0; i < uniqueCategory.count; i++){
        NSMutableArray *categoryArray = [[NSMutableArray alloc] init];
        for (EquipmentsTool *equipment in objectsArray) {
            if ([equipment.category isEqualToString:[NSString stringWithFormat:@"%@", uniqueCategory[i]] ]) {
                [categoryArray addObject:equipment];
            }
        }
        
        NSArray *sortedCategoryArray = [categoryArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            NSString *categotyOne = [(EquipmentsTool*)obj1 name];
            NSString *categotyTwo = [(EquipmentsTool*)obj2 name];
            return [categotyOne compare:categotyTwo];
        }];
        
        [arrayWithCategorisedArrays addObject:[sortedCategoryArray mutableCopy]];
    }
    return arrayWithCategorisedArrays;
}

- (NSMutableArray *)categoryType: (NSArray *)objectsArray
{
    NSCountedSet *toolsWithCounts = [NSCountedSet setWithArray:[objectsArray valueForKey:@"category"]];
    NSArray *uniqueCategory = [[toolsWithCounts allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *categotyOne = (NSString *)obj1;
        NSString *categotyTwo = (NSString *)obj2;
        return [categotyOne compare:categotyTwo];
    }];
    return [NSMutableArray arrayWithArray:uniqueCategory];
}

- (void)deleteSelectedItem:(NSIndexPath*)indexPathToDelete
{
    EquipmentsTool *eq = ((EquipmentsTool *)((NSArray *)self.arrayWithCategorisedToolsArrays[indexPathToDelete.section])[indexPathToDelete.row]);
    [self.specManager.currentProcedure removeEquipmentsObject:eq];
    NSError *saveDeletedObjectsError;
    [self.managedObjectContext deleteObject:eq];
    if(![self.managedObjectContext save:&saveDeletedObjectsError]) {
        NSLog(@"Cant delete from DB, error : %@", saveDeletedObjectsError.localizedDescription);
    }
    if ([self.cellCurrentlyEditing containsObject:indexPathToDelete]) {
        [self.cellCurrentlyEditing removeObject:indexPathToDelete];
    }
    if ([self.cellWithCheckedButtons containsObject:indexPathToDelete]) {
        [self.cellWithCheckedButtons removeObject:indexPathToDelete];
    }
    NSMutableArray *arrayWithIndex = [NSMutableArray arrayWithArray:[self.cellWithCheckedButtons allObjects]];
    [self.cellWithCheckedButtons removeAllObjects];
    NSMutableArray *buffer = [[NSMutableArray alloc] init];
    for (NSIndexPath *index in arrayWithIndex){
        if (index.section == indexPathToDelete.section && index.row > indexPathToDelete.row) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index.row-1 inSection:index.section];
            [buffer addObject:newIndexPath];
        } else {
            [buffer addObject:index];
        }
        if ( [self.arrayWithCategorisedToolsArrays[indexPathToDelete.section] count] == 1 && index.section>indexPathToDelete.section ) {
            NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:index.row inSection:index.section-1];
            [buffer removeObject:index];
            [buffer addObject:newIndexPath];
        }
    }
    self.cellWithCheckedButtons = [NSMutableSet setWithArray:buffer];
    NSInteger sectionCount = self.arrayWithCategorisedToolsArrays.count;
    [self.arrayWithCategorisedToolsArrays[indexPathToDelete.section] removeObjectAtIndex:indexPathToDelete.row];
    if ( [self.arrayWithCategorisedToolsArrays[indexPathToDelete.section] count] == 0) {
        [self.arrayWithCategorisedToolsArrays removeObjectAtIndex:indexPathToDelete.section];
        [self.categoryTools removeObject:self.categoryTools[indexPathToDelete.section]];
    }
    if (self.arrayWithCategorisedToolsArrays.count < sectionCount) {
        [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPathToDelete.section] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, sectionCount)] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (NSMutableString *)getMessageBody
{
    NSMutableString *message = [[NSMutableString alloc] init];
    
    NSMutableArray *selectedCategories = [[NSMutableArray alloc] init];
    for (NSIndexPath *indexWithSelectedCells in self.cellWithCheckedButtons){
        [selectedCategories addObject:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).category];
    }
    NSArray *uniqueCategories = [[NSSet setWithArray:selectedCategories] allObjects];
    
    for (int i = 0; i < uniqueCategories.count; i++) {
        [message appendString:[NSString stringWithFormat:@"<b>%@</b><br>", uniqueCategories[i]]];
            
        for (NSIndexPath *indexWithSelectedCells in self.cellWithCheckedButtons) {
            if ([((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).category isEqualToString:uniqueCategories[i]]) {
                
                NSMutableString *descriptionOfEquipment = [[NSMutableString alloc] init];
                [descriptionOfEquipment appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).name];
                if (![((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).type isEqualToString:@""]) {
                    [descriptionOfEquipment appendString:@", "];
                    [descriptionOfEquipment appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).type];
                }
                if (![((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).quantity isEqualToString:@""]) {
                    [descriptionOfEquipment appendString:@", "];
                    [descriptionOfEquipment appendString:((EquipmentsTool*)(self.arrayWithCategorisedToolsArrays[indexWithSelectedCells.section])[indexWithSelectedCells.row]).quantity];
                }

                [message appendString:[NSString stringWithFormat:@"%@<br>" ,descriptionOfEquipment]];
            }
        }
        [message appendString:@"<br>"];
    }
    return message;
}

@end
