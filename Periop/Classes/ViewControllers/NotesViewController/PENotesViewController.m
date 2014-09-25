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
#import "PECoreDataManager.h"
#import "Doctors.h"

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate, PENotesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;

@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) UILabel* navigationBarLabel;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end

#pragma mark - Lifecycle

@implementation PENotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    if (self.specManager.isProcedureSelected) {
        self.navigationBarLabel.text = ((Procedure*)self.specManager.currentProcedure).name;
    } else {
        self.navigationBarLabel.text = ((Doctors*)self.specManager.currentDoctor).name;
    }
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.numberOfLines = 0;
    
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
    addEditNote.isEditNote = false;
    [self.navigationController pushViewController:addEditNote animated:YES];
}

#pragma marl - TableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.specManager.isProcedureSelected) {
        return self.specManager.currentProcedure.notes.count;
    } else
        return self.specManager.currentDoctor.notes.count;
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
    if (self.specManager.isProcedureSelected && [self.specManager.currentProcedure.notes allObjects][indexPath.row]!=nil) {
        cell.label.text = ((Note*)([self.specManager.currentProcedure.notes allObjects][indexPath.row])).textDescription;
        cell.titleLabel.text = [self dateFormatter:((Note*)([self.specManager.currentProcedure.notes allObjects][indexPath.row])).timeStamp];
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentDoctor.notes allObjects][indexPath.row]!=nil) {
        cell.label.text = ((Note*)([self.specManager.currentDoctor.notes allObjects][indexPath.row])).textDescription;
        cell.titleLabel.text = [self dateFormatter:((Note*)([self.specManager.currentDoctor.notes allObjects][indexPath.row])).timeStamp];
    }
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
    NSIndexPath * currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note*)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
        NSError * deleteError = nil;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Procedure - %@", deleteError.localizedDescription);
        }
    } else {
        self.specManager.currentNote = (Note*)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
        NSError * deleteError = nil;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Doctor - %@", deleteError.localizedDescription);
        }
    }
    [self.tableViewNotes reloadData];
}

- (void) addPhotoButtonPress:(UITableViewCell *)cell
{
    NSLog(@"add Button");
}

- (void) editNoteButtonPress:(UITableViewCell *)cell
{
    NSIndexPath * currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    PEAddEditNoteViewController * addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note*)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
    } else {
        self.specManager.currentNote = (Note*)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
    }
    addEditNote.noteTextToShow = self.specManager.currentNote.textDescription;
    addEditNote.timeToShow = [self dateFormatter:self.specManager.currentNote.timeStamp];
    addEditNote.isEditNote = true;
    [self.navigationController pushViewController:addEditNote animated:YES];
}

#pragma mark - Private

- (NSString*)dateFormatter: (NSDate*)dateToFormatt
{
    NSDateFormatter * dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter * dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

@end
