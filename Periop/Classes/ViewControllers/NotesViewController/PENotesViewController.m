//
//  PENotesViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const NVCNotesCellIdentifier = @"notesCell";
static NSString *const NVCNotesCellNibName = @"PENotesTableViewCell";
static CGFloat const NVCNotesBottomButtonHeight = 38.0f;
static CGFloat const NVCNotesBackButtonNegativeOffcet = -8.0f;

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
#import "PEProcedureListViewController.h"

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate, PENotesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightOfBottomButtons;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

#pragma mark - Lifecycle

@implementation PENotesViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Add"] style:UIBarButtonItemStyleBordered target:self action:@selector(addNewNotes:)];
    self.navigationItem.rightBarButtonItem = addButton;
    
    [self.tableViewNotes registerNib:[UINib nibWithNibName:NVCNotesCellNibName bundle:nil] forCellReuseIdentifier:NVCNotesCellIdentifier];
    self.tableViewNotes.delegate = self;
    self.tableViewNotes.dataSource = self;
    
    if (self.isDoctorsNote) {
        self.constraintHeightOfBottomButtons.constant = NVCNotesBottomButtonHeight;
        self.navigationItem.hidesBackButton = YES;
        
        UIImage *backButtonImage = [UIImage imageNamed:@"Back"];
        
        CGPoint size = CGPointMake(backButtonImage.size.width * 2 , backButtonImage.size.height * 2);
        UIImage *scaledImage = [UIImage imageWithImage:backButtonImage scaledToSize:CGSizeMake(size.x, size.y)];
        
        UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, scaledImage.size.width, scaledImage.size.height)];
        [backButton setImage:scaledImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(backToDoctorsList:) forControlEvents:UIControlEventTouchDown];
        UIBarButtonItem *backBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        
        UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        negativeSpacer.width = NVCNotesBackButtonNegativeOffcet;
        [self.navigationItem setLeftBarButtonItems:[NSArray arrayWithObjects: negativeSpacer, backBarButton, nil] animated:NO];
    }
}

- (IBAction)backToDoctorsList:(id)sender
{
    id viewController = self.navigationController.viewControllers[[self.navigationController.viewControllers count]-3];
    [self.navigationController popToViewController:viewController animated:YES];
}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *textForHeader;
    if (self.specManager.isProcedureSelected) {
        textForHeader = ((Procedure *)self.specManager.currentProcedure).name;
    } else {
        textForHeader = ((Doctors *)self.specManager.currentDoctor).name;
    }
    ((PENavigationController *)self.navigationController).titleLabel.text = textForHeader;
    
    [self.tableViewNotes reloadData];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    self.tableViewNotes.contentInset = UIEdgeInsetsZero;
    self.tableViewNotes.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)specButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:NO];
}

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
    PENotesTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NVCNotesCellIdentifier forIndexPath:indexPath];
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

- (PENotesTableViewCell *)configureCell:(PENotesTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if (self.specManager.isProcedureSelected && [self.specManager.currentProcedure.notes allObjects][indexPath.row]!=nil) {
        cell.label.text = ((Note *)([self.specManager.currentProcedure.notes allObjects][indexPath.row])).textDescription;
        cell.titleLabel.text = [self dateFormatter:((Note *)([self.specManager.currentProcedure.notes allObjects][indexPath.row])).timeStamp];
    } else if (!self.specManager.isProcedureSelected && [self.specManager.currentDoctor.notes allObjects][indexPath.row]!=nil) {
        cell.label.text = ((Note *)([self.specManager.currentDoctor.notes allObjects][indexPath.row])).textDescription;
        cell.titleLabel.text = [self dateFormatter:((Note *)([self.specManager.currentDoctor.notes allObjects][indexPath.row])).timeStamp];
    }
    cell.delegate = self;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *) indexPath
{
    static PENotesTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableViewNotes dequeueReusableCellWithIdentifier:NVCNotesCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewNotes.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - PENotesTableViewCellDelegate

- (void)deleteNotesButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note *)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
        NSError *deleteError;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Procedure - %@", deleteError.localizedDescription);
        }
    } else {
        self.specManager.currentNote = (Note *)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
        NSError *deleteError;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Doctor - %@", deleteError.localizedDescription);
        }
    }
    [self.tableViewNotes reloadData];
}

- (void)addPhotoButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note *)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
    } else {
        self.specManager.currentNote = (Note *)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
    }
    
    if ([UIImage imageWithData:((Photo *)self.specManager.currentNote.photo).photoData]!= nil) {
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        viewPhotoControleller.photoToShow = (Photo *)self.specManager.currentNote.photo;
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

- (void)editNoteButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    PEAddEditNoteViewController *addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
    if (self.specManager.isProcedureSelected) {
        self.specManager.currentNote = (Note *)[self.specManager.currentProcedure.notes allObjects][currentIndexPath.row];
    } else {
        self.specManager.currentNote = (Note *)[self.specManager.currentDoctor.notes allObjects][currentIndexPath.row];
    }
    addEditNote.noteTextToShow = self.specManager.currentNote.textDescription;
    addEditNote.timeToShow = [self dateFormatter:self.specManager.currentNote.timeStamp];
    addEditNote.isEditNote = true;
    [self.navigationController pushViewController:addEditNote animated:YES];
}

#pragma mark - Private

- (NSString *)dateFormatter:(NSDate *)dateToFormatt
{
    NSDateFormatter *dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter *dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

@end
