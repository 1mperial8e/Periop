//
//  PENotesViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PENotesViewController.h"
#import "PENotesTableViewCell.h"
#import <QuartzCore/QuartzCore.h>
#import "PEAddEditNoteViewController.h"

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;
@property (strong, nonatomic) UILabel* navigationBarLabel;

@end

#pragma mark - Lifecycle

@implementation PENotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    navigationLabel.text =self.navigationLabelText;
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel = navigationLabel;
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithTitle:@"+" style:UIBarButtonItemStyleBordered target:self action:@selector(addNewNotes:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self.tableViewNotes registerNib:[UINib nibWithNibName:@"PENotesTableViewCell" bundle:nil] forCellReuseIdentifier:@"notesCell"];
    
    self.tableViewNotes.delegate = self;
    self.tableViewNotes.dataSource = self;
}


- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)addNewNotes :(id)sender{
    PEAddEditNoteViewController * addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
    [self.navigationController pushViewController:addEditNote animated:NO];
}

#pragma marl - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PENotesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"notesCell" forIndexPath:indexPath];
    if (!cell){
        cell = [[PENotesTableViewCell alloc] init];
    }
    cell.label.layer.cornerRadius = 4;
    cell.label.layer.borderColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1] CGColor];
    cell.label.layer.borderWidth = 1.0;
    cell = [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma mark - DynamicHeightOfCell

- (PENotesTableViewCell*)configureCell: (PENotesTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath{
    cell.label.text = [NSString stringWithFormat:@"Notes number %d", [indexPath row]];
    if (indexPath.row ==1){
        cell.label.text = @"biggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbiggggbigggg Text";
    }
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath: (NSIndexPath*) indexPath{
    static PENotesTableViewCell * sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^{
        sizingCell = [self.tableViewNotes dequeueReusableCellWithIdentifier:@"notesCell"];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewNotes.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}


@end
