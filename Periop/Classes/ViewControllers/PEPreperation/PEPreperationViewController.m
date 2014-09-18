//
//  PEPreperationViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPreperationViewController.h"
#import "PEPreparationTableViewCell.h"

#import "PECoreDataManager.h"
#import "PESpecialisationManager.h"
#import "Preparation.h"
#import "Procedure.h"

@interface PEPreperationViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) PESpecialisationManager * manager;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end

@implementation PEPreperationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Preperation"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:16.0]
                  range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:@"\nProcedureName"];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
   
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    self.navigationBarLabel.attributedText = stringForLabelTop;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEPreparationTableViewCell" bundle:nil] forCellReuseIdentifier:@"preparationCell"];
    
    self.manager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return  [self.manager.currentProcedure.preparation count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    PEPreparationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"preparationCell"];
    if (!cell){
        cell = [[PEPreparationTableViewCell alloc] init];
    }
    //cell.textLabel.text = [NSString stringWithFormat:@"Preperation %d ", indexPath.row ];
     cell = [self configureCell:cell atIndexPath:indexPath];
    return cell;    
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma mark - DynamicHeightOfCell

- (PEPreparationTableViewCell *)configureCell: (PEPreparationTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath{
    
    cell.labelStep.text = [NSString stringWithFormat:@"Step %i", (int)[indexPath row]];
    cell.labelPreparationText.text = ((Preparation*)([self.manager.currentProcedure.preparation allObjects][indexPath.row])).preparationText;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath: (NSIndexPath*) indexPath{
    static PEPreparationTableViewCell * sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^{
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"preparationCell"];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}


@end
