//
//  PEPatientPositioningViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPatientPositioningViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEPatientPositioningTableViewCell.h"
#import "PEMediaSelect.h"
#import "Procedure.h"
#import "PESpecialisationManager.h"
#import "PEAlbumViewController.h"
#import "Photo.h"
#import "PatientPostioning.h"
#import <QuartzCore/QuartzCore.h>
#import "PEViewPhotoViewController.h"
#import "Steps.h"
#import "PECameraViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PEAddEditStepViewControllerViewController.h"
#import "PECoreDataManager.h"

static NSString *const PPOperationRoomCollectionViewCellNibName = @"PEOperationRoomCollectionViewCell";
static NSString *const PPOperationRoomCollectionViewCellIdentifier = @"OperationRoomViewCell";
static NSString *const PPPatientPositioningTableViewCellNibName = @"PEPatientPositioningTableViewCell";
static NSString *const PPPatientPositioningTableViewCellIdentifier = @"patientPositioningStepsCell";

static NSString *const PPImagePlaceHolder = @"Place_Holder";
static NSInteger const PPTagView = 35;

@interface PEPatientPositioningViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, PEPatientPositioningTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *postedCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPatient;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithPhotos;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithPatientPositioning;

@property (strong, nonatomic) UIBarButtonItem *addStepButton;
@property (strong, nonatomic) UIBarButtonItem *editStepButton;

@property (strong, nonatomic) NSMutableArray *swipedCells;

@end

@implementation PEPatientPositioningViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.postedCollectionView registerNib:[UINib nibWithNibName:PPOperationRoomCollectionViewCellNibName bundle:nil] forCellWithReuseIdentifier:PPOperationRoomCollectionViewCellIdentifier];
    [self.tableViewPatient registerNib:[UINib nibWithNibName:PPPatientPositioningTableViewCellNibName bundle:nil] forCellReuseIdentifier:PPPatientPositioningTableViewCellIdentifier];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.postedCollectionView.delegate = self;
    self.postedCollectionView.dataSource = self;
    
    self.tableViewPatient.delegate = self;
    self.tableViewPatient.dataSource = self;
    
    self.tableViewPatient.layer.borderWidth = 0.0f;
    self.postedCollectionView.layer.borderWidth = 0.0f;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Patient Positioning"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:20.0] range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure*)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:13.5] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    [(PEMediaSelect *)[self.view viewWithTag:PPTagView] setVisible:NO];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.patientPostioning.photo allObjects]];
 
    self.pageControll.numberOfPages = self.sortedArrayWithPhotos.count;
    [self.postedCollectionView reloadData];

    self.navigationItem.rightBarButtonItem = self.addStepButton;
    [self createBarButtons];
    [self refreshData];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma marks - IBActions

- (IBAction)operationWithPhotoButton:(id)sender
{
    CGRect size = self.postedCollectionView.bounds;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = array[0];
    view.frame = size;
    view.tag = PPTagView;
    [self.view addSubview:view];
    [view setVisible:YES];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure *)(self.specManager.currentProcedure)).name;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = PatientPostioningViewController;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [(PEMediaSelect *)[self.view viewWithTag:PPTagView] setVisible:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.specManager.currentProcedure.patientPostioning.steps allObjects].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEPatientPositioningTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PPPatientPositioningTableViewCellIdentifier forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEPatientPositioningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:PPPatientPositioningTableViewCellIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
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
    PEPatientPositioningTableViewCell *cell = (PEPatientPositioningTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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

- (PEPatientPositioningTableViewCell *)configureCell:(PEPatientPositioningTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.labelStepName.text = ((Steps *)self.sortedArrayWithPatientPositioning[indexPath.row]).stepName;
    cell.labelContent.text = ((Steps *)self.sortedArrayWithPatientPositioning[indexPath.row]).stepDescription;
    
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static PEPatientPositioningTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableViewPatient dequeueReusableCellWithIdentifier:PPPatientPositioningTableViewCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableViewPatient.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height ;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.sortedArrayWithPhotos.count >0) {
        return self.sortedArrayWithPhotos.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEOperationRoomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PPOperationRoomCollectionViewCellIdentifier forIndexPath:indexPath];
    if (self.sortedArrayWithPhotos.count>0) {
        cell.operationRoomImage.image = [UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData];
        self.pageControll.currentPage = [indexPath row];
    } else {
        cell.operationRoomImage.image = [UIImage imageNamedFile:PPImagePlaceHolder];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sortedArrayWithPhotos.count && [((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData hash]!= [[UIImage imageNamedFile:PPImagePlaceHolder] hash]) {
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        if (self.sortedArrayWithPhotos.count) {
            viewPhotoControleller.photoToShow = (Photo*)self.sortedArrayWithPhotos[indexPath.row];
        }
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

#pragma mark - PEPatientPositioningTableViewCellDelegate

- (void)cellSwipedIn:(UITableViewCell *)cell
{
    NSIndexPath *swipedIndexPath = [self.tableViewPatient indexPathForCell:cell];
    [self.swipedCells removeObject:swipedIndexPath];
}

-(void)cellSwipedOut:(UITableViewCell *)cell
{
    NSIndexPath *swipedIndexPath = [self.tableViewPatient indexPathForCell:cell];
    if (!self.swipedCells) {
        self.swipedCells = [[NSMutableArray alloc] init];
    }
    [self.swipedCells addObject:swipedIndexPath];
}

- (void)buttonDeleteAction:(UITableViewCell *)cell
{
    NSLog(@"delete");
    NSIndexPath *indexPathToDelete = [self.tableViewPatient indexPathForCell:cell];
    [self.managedObjectContext deleteObject:self.sortedArrayWithPatientPositioning[indexPathToDelete.row]];
    
    for (int i = (int)indexPathToDelete.row; i < self.sortedArrayWithPatientPositioning.count; i++) {
        for (Steps *step in [self.specManager.currentProcedure.patientPostioning.steps allObjects]) {
            if ([step.stepName isEqualToString:((Steps *)self.sortedArrayWithPatientPositioning[i]).stepName]) {
                step.stepName = [NSString stringWithFormat:@"Step %i", i];
            }
        }
    }
    [self.swipedCells removeAllObjects];
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Cant delete patient positioning Step - %@", error.localizedDescription);
    }
    ((PEPatientPositioningTableViewCell *)cell).deleteButton.hidden = YES;
    [self refreshData];
}

#pragma mark - Private

- (void)refreshData
{
    self.sortedArrayWithPatientPositioning = [self sortedArrayWithPatientPos:[self.specManager.currentProcedure.patientPostioning.steps allObjects]];
    [self.tableViewPatient reloadData];
}

- (NSMutableArray *)sortedArrayWithPhotos:(NSArray*)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *firstObject = [(Photo*)obj1 photoNumber];
        NSNumber *secondObject = [(Photo*)obj2 photoNumber];
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray *)sortedArrayWithPatientPos:(NSArray *)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = [(Steps*)obj1 stepName ];
        NSString *secondObject = [(Steps*)obj2 stepName];
        return [firstObject compare:secondObject options:NSNumericSearch];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
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
     NSIndexPath *selectedIndexPath = self.tableViewPatient.indexPathsForSelectedRows[0];
    
    PEAddEditStepViewControllerViewController *editStepController = [PEAddEditStepViewControllerViewController new];
    editStepController.entityName = PEStepEntityNamePatientPositioning;
    if (sender == self.addStepButton) {
        editStepController.stepNumber = [NSString stringWithFormat:@"Step %i", (int)(self.specManager.currentProcedure.patientPostioning.steps.count + 1)];
        editStepController.stepText = @"";
    } else {
        PEPatientPositioningTableViewCell *cell = (PEPatientPositioningTableViewCell *)[self.tableViewPatient cellForRowAtIndexPath:self.tableViewPatient.indexPathForSelectedRow];
        editStepController.stepNumber = cell.labelStepName.text;
        editStepController.stepText = cell.labelContent.text;
        self.specManager.currentStep = self.sortedArrayWithPatientPositioning[selectedIndexPath.row];
    }
    [self.navigationController pushViewController:editStepController animated:YES];
}

@end
