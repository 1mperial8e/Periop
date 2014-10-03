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
#import "PEViewPhotoViewController.h"
#import "UIImage+ImageWithJPGFile.h"

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate, PENotesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

#pragma mark - Lifecycle

@implementation PENotesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewNotes:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self.tableViewNotes registerNib:[UINib nibWithNibName:@"PENotesTableViewCell" bundle:nil] forCellReuseIdentifier:@"notesCell"];
    self.tableViewNotes.delegate = self;
    self.tableViewNotes.dataSource = self;
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *textForHeader;
    if (self.specManager.isProcedureSelected) {
        textForHeader = ((Procedure*)self.specManager.currentProcedure).name;
    } else {
        textForHeader = ((Doctors*)self.specManager.currentDoctor).name;
    }
    ((PENavigationController *)self.navigationController).titleLabel.text = textForHeader;
    
    [self.tableViewNotes reloadData];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)addNewNotes :(id)sender
{
    PEAddEditNoteViewController *addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
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
    PENotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notesCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PENotesTableViewCell alloc] init];
    }
    UIImage *buttonImage = [UIImage imageNamedFile:@"Edit"];
    cell.cornerLabel.layer.cornerRadius = buttonImage.size.height/2;
    cell.cornerLabel.layer.borderColor = [UIColorFromRGB(0xE0E0E0) CGColor];
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
    static PENotesTableViewCell *sizingCell = nil;
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
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note*)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
        NSError *deleteError = nil;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Procedure - %@", deleteError.localizedDescription);
        }
    } else {
        self.specManager.currentNote = (Note*)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
        NSError *deleteError = nil;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Doctor - %@", deleteError.localizedDescription);
        }
    }
    [self.tableViewNotes reloadData];
}

- (void) addPhotoButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note*)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
    } else {
        self.specManager.currentNote = (Note*)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
    }
    
    if ([UIImage imageWithData:((Photo*)self.specManager.currentNote.photo).photoData]!= nil) {
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        viewPhotoControleller.photoToShow = (Photo*)self.specManager.currentNote.photo;
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

- (void) editNoteButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    PEAddEditNoteViewController *addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
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
    NSDateFormatter *dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter *dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

@end
