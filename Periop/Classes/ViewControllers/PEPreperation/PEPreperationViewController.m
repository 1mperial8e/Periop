//
//  PEPreperationViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPreperationViewController.h"
#import "PEPreparationTableViewCell.h"
#import "PEAddEditStepViewControllerViewController.h"
#import "PECoreDataManager.h"
#import "PESpecialisationManager.h"
#import "Preparation.h"
#import "Procedure.h"

static NSString *const PPreparationTableViewCellNibName = @"PEPreparationTableViewCell";
static NSString *const PPreparationTableViewCellIdentifier =  @"preparationCell";

@interface PEPreperationViewController () <UITableViewDataSource, UITableViewDelegate, PEPreparationTableViewCellDelegate>

@property (strong, nonatomic) UILabel *navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *sortedArrayWithPreprations;

@property (strong, nonatomic) UIBarButtonItem *addStepButton;
@property (strong, nonatomic) UIBarButtonItem *editStepButton;

@property (strong, nonatomic) NSMutableArray *swipedCells;

@end

@implementation PEPreperationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self createBarButtons];
    [self.tableView registerNib:[UINib nibWithNibName:PPreparationTableViewCellNibName bundle:nil] forCellReuseIdentifier:PPreparationTableViewCellIdentifier];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableView.contentInset = UIEdgeInsetsZero;
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Preperation"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont fontWithName:FONT_MuseoSans300 size:20.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure*)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:13.5] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    self.navigationItem.rightBarButtonItem = self.addStepButton;
    
    [self refreshData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.specManager.currentProcedure.preparation.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    PEPreparationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PPreparationTableViewCellIdentifier];
    if (!cell) {
        cell = [[PEPreparationTableViewCell alloc] init];
    }
     cell = [self configureCell:cell atIndexPath:indexPath];
    cell.delegate = self;
    if ([self.swipedCells containsObject:indexPath]) {
        [cell setCellSwiped];
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEPreparationTableViewCell *cell = (PEPreparationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    BOOL selected = cell.selected;
    if (selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        self.navigationItem.rightBarButtonItem = self.addStepButton;
    }
    if (cell.customContentView.frame.origin.x) {
        return NO;
    }
    return !selected;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.rightBarButtonItem = self.editStepButton;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.navigationItem.rightBarButtonItem = self.addStepButton;
}

#pragma mark - DynamicHeightOfCell

- (PEPreparationTableViewCell *)configureCell: (PEPreparationTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{    
    cell.labelStep.text = ((Preparation *)self.sortedArrayWithPreprations[indexPath.row]).stepName;
    cell.labelPreparationText.text = ((Preparation *)self.sortedArrayWithPreprations[indexPath.row]).preparationText;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *) indexPath
{
    static PEPreparationTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:PPreparationTableViewCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma marks - Private

- (NSArray *)sortedArrayWithPreparationSteps:(NSArray *)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = ((Preparation*)obj1).stepName;
        NSString *secondObject = ((Preparation*)obj2).stepName;
        return [firstObject compare:secondObject options:NSNumericSearch];
    }];
    return sortedArray;
}

- (void)createBarButtons
{
    UIImage *addImage = [UIImage imageNamed:@"Add"];
    UIImage *editImage = [UIImage imageNamed:@"Edit_Info"];
    self.addStepButton = [[UIBarButtonItem alloc] initWithImage:addImage style:UIBarButtonItemStylePlain target:self action:@selector(editStep:)];
    self.editStepButton = [[UIBarButtonItem alloc] initWithImage:editImage style:UIBarButtonItemStylePlain target:self action:@selector(editStep:)];
    
    self.navigationItem.rightBarButtonItem = self.addStepButton;
}

- (void)editStep:(UIBarButtonItem *)sender
{
    NSIndexPath *selectedIndexPath = self.tableView.indexPathsForSelectedRows[0];
    
    PEAddEditStepViewControllerViewController *editStepController = [PEAddEditStepViewControllerViewController new];
    editStepController.entityName = PEStepEntityNamePreparation;
    if (sender == self.addStepButton) {
        editStepController.stepNumber = [NSString stringWithFormat:@"Step %i", (int)(self.specManager.currentProcedure.preparation.count + 1)];
        editStepController.stepText = @"";
    } else {
        PEPreparationTableViewCell *cell = (PEPreparationTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        editStepController.stepNumber = cell.labelStep.text;
        editStepController.stepText = cell.labelPreparationText.text;
        self.specManager.currentPreparation = self.sortedArrayWithPreprations[selectedIndexPath.row];
    }
    [self.navigationController pushViewController:editStepController animated:YES];
}

- (void)refreshData
{
    self.sortedArrayWithPreprations =[self sortedArrayWithPreparationSteps:[self.specManager.currentProcedure.preparation allObjects]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

#pragma mark - PEPreparationTableViewCellDelegate

- (void)cellSwipedIn:(UITableViewCell *)cell
{
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
    [self.swipedCells removeObject:swipedIndexPath];
}

-(void)cellSwipedOut:(UITableViewCell *)cell
{
    NSIndexPath *swipedIndexPath = [self.tableView indexPathForCell:cell];
    if (!self.swipedCells) {
        self.swipedCells = [[NSMutableArray alloc] init];
    }
    [self.swipedCells addObject:swipedIndexPath];
}

- (void)buttonDeleteAction:(UITableViewCell *)cell
{
    NSIndexPath *indexPathToDelete = [self.tableView indexPathForCell:cell];
    [self.managedObjectContext deleteObject:self.sortedArrayWithPreprations[indexPathToDelete.row]];
    
    for (int i = (int)indexPathToDelete.row; i < self.sortedArrayWithPreprations.count; i++){
        for (Preparation *step in [self.specManager.currentProcedure.preparation allObjects]) {
            if ([step.stepName isEqualToString:((Preparation *)self.sortedArrayWithPreprations[i]).stepName]) {
                step.stepName = [NSString stringWithFormat:@"Step %i", i];
            }
        }
    }
    [self.swipedCells removeAllObjects];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant delete preparation Step - %@", error.localizedDescription);
    }
    ((PEPreparationTableViewCell *)cell).deleteButton.hidden = YES;
    [self refreshData];
}

@end
