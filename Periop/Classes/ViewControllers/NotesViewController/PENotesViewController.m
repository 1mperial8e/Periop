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
#import "Procedure.h"
#import "PESpecialisationManager.h"
#import "PEAlbumViewController.h"
#import "Note.h"

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate, PENotesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;

@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) UILabel* navigationBarLabel;

@end

#pragma mark - Lifecycle

@implementation PENotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.text = ((Procedure*)self.specManager.currentProcedure).name;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem * addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewNotes:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self.tableViewNotes registerNib:[UINib nibWithNibName:@"PENotesTableViewCell" bundle:nil] forCellReuseIdentifier:@"notesCell"];
    self.tableViewNotes.delegate = self;
    self.tableViewNotes.dataSource = self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [self.tableViewNotes reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)addNewNotes :(id)sender
{
    PEAddEditNoteViewController * addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
    [self.navigationController pushViewController:addEditNote animated:NO];
}

#pragma marl - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.specManager.currentProcedure.notes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PENotesTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"notesCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PENotesTableViewCell alloc] init];
    }
    UIImage * buttonImage = [UIImage imageNamed:@"Edit"];
    cell.cornerLabel.layer.cornerRadius = buttonImage.size.height/2;
    cell.cornerLabel.layer.borderColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1] CGColor];
    cell.cornerLabel.layer.borderWidth = 1.0;
    cell = [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma mark - DynamicHeightOfCell

- (PENotesTableViewCell*)configureCell: (PENotesTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
//    cell.label.text = [NSString stringWithFormat:@"Notes number %d", [indexPath row]];
//    if (indexPath.row ==1) {
//        cell.label.text = @"biggggbiggg gbiggggb iggggbiggggb iggggbig gggbiggggbig ggbiggggbiggggbigg ggbiggggbigg ggbiggggbiggggbigggg biggggbiggggbigg ggbiggggbiggggbig gggbiggggbiggggbiggggbiggggbiggggb iggggbi ggggbigg  ggbiggggbig gggbigggg Text";
//    }
    cell.label.text = ((Note*)([self.specManager.currentProcedure.notes allObjects][indexPath.row])).textDescription;
    cell.delegate = self;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath: (NSIndexPath*) indexPath
{
    static PENotesTableViewCell * sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableViewNotes dequeueReusableCellWithIdentifier:@"notesCell"];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewNotes.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height ;
}

#pragma mark - PENotesTableViewCellDelegate

- (void) deleteNotesButtonPress:(UITableViewCell *)cell
{
    NSLog(@"delete Button");
}

- (void) addPhotoButtonPress:(UITableViewCell *)cell
{
    NSLog(@"add Button");
}

- (void) editNoteButtonPress:(UITableViewCell *)cell
{
    NSLog(@"edit Button");
}


@end
