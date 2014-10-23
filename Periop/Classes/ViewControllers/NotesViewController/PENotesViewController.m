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
#import "PEProcedureListViewController.h"
#import "Photo.h"

static NSString *const NVCNotesCellIdentifier = @"notesCell";
static NSString *const NVCNotesCellNibName = @"PENotesTableViewCell";
static CGFloat const NVCNotesBottomButtonHeight = 38.0f;
static CGFloat const NVCNotesBackButtonNegativeOffcet = -8.0f;

@interface PENotesViewController () <UITableViewDataSource, UITableViewDelegate, PENotesTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableViewNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintHeightOfBottomButtons;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong, nonatomic) NSArray *arrayWithSortedNotes;

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
    
    UIBarButtonItem *buttonBack = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:@selector(backToDoctorsList:)];
    self.navigationItem.backBarButtonItem = buttonBack;
    
    [self.tableViewNotes registerNib:[UINib nibWithNibName:NVCNotesCellNibName bundle:nil] forCellReuseIdentifier:NVCNotesCellIdentifier];
    self.tableViewNotes.delegate = self;
    self.tableViewNotes.dataSource = self;
    
    if (self.isDoctorsNote) {
        self.constraintHeightOfBottomButtons.constant = NVCNotesBottomButtonHeight;
        self.navigationItem.hidesBackButton = YES;
        
        UIImage *backButtonImage = [UIImage imageNamedFile:@"Back"];
        
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
    
    [self updateDataSource];    
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
    return self.arrayWithSortedNotes.count;
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
    cell.photoButton.hidden = YES;
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
    if ([((Note *)(self.arrayWithSortedNotes[indexPath.row])).photo allObjects].count) {
        cell.photoButton.hidden = NO;
    }
    cell.label.text = ((Note *)(self.arrayWithSortedNotes[indexPath.row])).textDescription;
    cell.timestampLabel.text = [self dateFormatter:((Note *)(self.arrayWithSortedNotes[indexPath.row])).timeStamp];
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
        self.specManager.currentNote = (Note *)self.arrayWithSortedNotes[currentIndexPath.row];
        NSError *deleteError;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Procedure - %@", deleteError.localizedDescription);
        }
    } else {
        self.specManager.currentNote = (Note *)self.arrayWithSortedNotes[currentIndexPath.row];
        NSError *deleteError;
        [self.managedObjectContext deleteObject:self.specManager.currentNote];
        if (![self.managedObjectContext save:&deleteError]) {
            NSLog(@"Cant delete note from Doctor - %@", deleteError.localizedDescription);
        }
    }
    [self updateDataSource];
    [self.tableViewNotes reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (void)addPhotoButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    self.specManager.currentNote = (Note *)self.arrayWithSortedNotes[currentIndexPath.row];
    
    if ([self.specManager.currentNote.photo allObjects].count) {
        self.navigationController.navigationBar.translucent = YES;
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
#warning to change
        viewPhotoControleller.photoToShow = [self.specManager.currentNote.photo allObjects][0];
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

- (void)editNoteButtonPress:(UITableViewCell *)cell
{
    NSIndexPath *currentIndexPath = [self.tableViewNotes indexPathForCell:cell];
    PEAddEditNoteViewController *addEditNote = [[PEAddEditNoteViewController alloc] initWithNibName:@"PEAddEditNoteViewController" bundle:nil];
    self.specManager.currentNote = (Note *)self.arrayWithSortedNotes[currentIndexPath.row];
    addEditNote.noteTextToShow = self.specManager.currentNote.textDescription;
    addEditNote.timeToShow = [self dateFormatter:self.specManager.currentNote.timeStamp];
    addEditNote.isEditNote = true;
    [self.navigationController pushViewController:addEditNote animated:YES];
}

#pragma mark - Private

- (void)updateDataSource
{
    if (self.specManager.isProcedureSelected) {
        self.arrayWithSortedNotes = [self sortedArrayWithNotes:[self.specManager.currentProcedure.notes allObjects]];
    } else {
        self.arrayWithSortedNotes = [self sortedArrayWithNotes:[self.specManager.currentDoctor.notes allObjects]];
    }
}

- (NSString *)dateFormatter:(NSDate *)dateToFormatt
{
    NSDateFormatter *dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter *dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

- (NSArray *)sortedArrayWithNotes:(NSArray *)arrayWithNotesToSort
{
    return [arrayWithNotesToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [((Note *)obj2).timeStamp compare:((Note *)obj1).timeStamp];
    }];
}

@end
