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

@interface PEPreperationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UILabel *navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *sortedArrayWithPreprations;

@property (strong, nonatomic) UIBarButtonItem *addStepButton;
@property (strong, nonatomic) UIBarButtonItem *editStepButton;

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
    
    self.sortedArrayWithPreprations =[self sortedArrayWithPreparationSteps:[self.specManager.currentProcedure.preparation allObjects]];
    
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
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure*)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
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
    return cell;    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL selected = ((UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath]).selected;
    if (selected) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        self.navigationItem.rightBarButtonItem = self.addStepButton;
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
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
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
        return [firstObject compare:secondObject];
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
    PEAddEditStepViewControllerViewController *editStepController = [PEAddEditStepViewControllerViewController new];
    editStepController.entityName = PEStepEntityNamePreparation;
    if (sender == self.addStepButton) {
        editStepController.stepNumber = [NSString stringWithFormat:@"Step %i", (int)(self.specManager.currentProcedure.preparation.count + 1)];
        editStepController.stepText = @"";
    } else {
        PEPreparationTableViewCell *cell = (PEPreparationTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        editStepController.stepNumber = cell.labelStep.text;
        editStepController.stepText = cell.labelPreparationText.text;
    }
    [self.navigationController pushViewController:editStepController animated:YES];
}

@end
