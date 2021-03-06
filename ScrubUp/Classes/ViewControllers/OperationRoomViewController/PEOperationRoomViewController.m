//
//  PEOperationRoomViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEOperationRoomViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEMediaSelect.h"
#import "PEOperationTableViewCell.h"
#import "Steps.h"
#import "PESpecialisationManager.h"
#import "OperationRoom.h"
#import "Procedure.h"
#import "PEAlbumViewController.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>
#import "PEViewPhotoViewController.h"
#import "PECameraViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PEAddEditStepViewControllerViewController.h"
#import "PECoreDataManager.h"
#import "PEBlurEffect.h"
#import "PELabelConfiguration.h"

static NSString *const OROperationRoomCollectionViewCellNibName = @"PEOperationRoomCollectionViewCell";
static NSString *const OROperationRoomCollectionViewCellIdentifier = @"OperationRoomViewCell";
static NSString *const OROperationTableViewCellNibName = @"PEOperationTableViewCell";
static NSString *const OROperationTableViewCellIdentifier = @"operationTableViewCell";

static NSString *const ORImagePlaceHolder = @"Place_Holder";
static NSInteger const ORTagView = 35;

@interface PEOperationRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, UIPageViewControllerDelegate, PEOperationTableViewCellDelegate, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *operationWithPhotoButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelSteps;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *sortedArrayWithPreprations;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithPhotos;

@property (strong, nonatomic) UIBarButtonItem *addStepButton;
@property (strong, nonatomic) UIBarButtonItem *editStepButton;

@property (strong, nonatomic) NSMutableArray *swipedCells;

@end

@implementation PEOperationRoomViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    self.labelSteps.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.layer.borderWidth = 0.0f;
    self.tableView.layer.borderWidth = 0.0f;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.collectionView registerNib:[UINib nibWithNibName:OROperationRoomCollectionViewCellNibName bundle:nil] forCellWithReuseIdentifier:OROperationRoomCollectionViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:OROperationTableViewCellNibName bundle:nil] forCellReuseIdentifier:OROperationTableViewCellIdentifier];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self createBarButtons];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operating Room"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:20.0] range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure *)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:13.5] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    [(PEMediaSelect *)[self.view viewWithTag:ORTagView] setVisible:NO];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.operationRoom.photo allObjects]];
    self.pageController.numberOfPages = self.sortedArrayWithPhotos.count;
    
    [self refreshData];
    
    [self.collectionView reloadData];

    self.navigationItem.rightBarButtonItem = self.addStepButton;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sortedArrayWithPhotos.count && [[UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData] hash] != [[UIImage imageNamedFile:ORImagePlaceHolder] hash]) {
        self.navigationController.navigationBar.translucent = YES;
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        if (self.sortedArrayWithPhotos.count) {
            viewPhotoControleller.photoToShow = (Photo*)self.sortedArrayWithPhotos[indexPath.row];
        }
        viewPhotoControleller.startPosition = indexPath.row;
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.sortedArrayWithPhotos.count) {
        return self.sortedArrayWithPhotos.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEOperationRoomCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OROperationRoomCollectionViewCellIdentifier forIndexPath:indexPath];
    if (self.sortedArrayWithPhotos.count) {
        UIImage *image = [UIImage imageWithData:((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoData];
        cell.operationRoomImage.image = image;
    } else {
        cell.operationRoomImage.image = [UIImage imageNamedFile:ORImagePlaceHolder];
    }
    return cell;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    for (NSIndexPath *indexPath in self.collectionView.indexPathsForVisibleItems) {
        PEOperationRoomCollectionViewCell *cell = (PEOperationRoomCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if (ABS(cell.frame.origin.x - self.collectionView.contentOffset.x) <= 50) {
            self.pageController.currentPage = indexPath.row;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.specManager.currentProcedure.operationRoom.steps.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEOperationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:OROperationTableViewCellIdentifier];
    if (!cell){
        cell = [[PEOperationTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:OROperationTableViewCellIdentifier];
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
    PEOperationTableViewCell *cell = (PEOperationTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
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

- (PEOperationTableViewCell *)configureCell:(PEOperationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.labelStep.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepName;
    cell.labelOperationRoomText.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepDescription;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath*)indexPath
{
    static PEOperationTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:OROperationTableViewCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), 0.0f);
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height;
}

#pragma mark - IBActions

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.collectionView.frame;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = array[0];
    view.frame = position;
    view.tag = ORTagView;

    [view addSubview:[PELabelConfiguration setInformationLabelOnView:view]];
    
    [self.view addSubview:view];
    [view setVisible:YES];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
    albumViewController.sortedArrayWithCurrentPhoto = self.sortedArrayWithPhotos;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.sortedArrayWithCurrentPhoto = self.sortedArrayWithPhotos;
    cameraView.request = OperationRoomViewController;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [(PEMediaSelect *)[self.view viewWithTag:ORTagView] setVisible:NO];
}

#pragma mark - PEOperationTableViewCellDelegate

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
    NSLog(@"delete");
    NSIndexPath *indexPathToDelete = [self.tableView indexPathForCell:cell];
    [self.managedObjectContext deleteObject:self.sortedArrayWithPreprations[indexPathToDelete.row]];
    
    for (int i = (int)indexPathToDelete.row; i < self.sortedArrayWithPreprations.count; i++) {
        for (Steps *step in [self.specManager.currentProcedure.operationRoom.steps allObjects]) {
            if ([step.stepName isEqualToString:((Steps *)self.sortedArrayWithPreprations[i]).stepName]) {
                step.stepName = [NSString stringWithFormat:@"Step %i", i];
            }
        }
    }
    [self.swipedCells removeAllObjects];

    [[PECoreDataManager sharedManager] save];
    ((PEOperationTableViewCell *)cell).deleteButton.hidden = YES;
    [self refreshData];
}

#pragma marks - Private

- (void)refreshData
{
    self.sortedArrayWithPreprations = [self sortedArrayWithPreparationSteps:[self.specManager.currentProcedure.operationRoom.steps allObjects]];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

- (NSArray *)sortedArrayWithPreparationSteps: (NSArray*)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = ((Steps*)obj1).stepName;
        NSString *secondObject = ((Steps*)obj2).stepName;
        return [firstObject compare:secondObject options:NSNumericSearch];
    }];
    return sortedArray;
}

- (NSMutableArray *)sortedArrayWithPhotos: (NSArray*)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *firstObject = ((Photo*)obj1).photoNumber;
        NSNumber *secondObject = ((Photo*)obj2).photoNumber;
        return [firstObject compare:secondObject];
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
    NSIndexPath *selectedIndexPath = self.tableView.indexPathsForSelectedRows[0];
    
    PEAddEditStepViewControllerViewController *editStepController = [PEAddEditStepViewControllerViewController new];
    editStepController.entityName = PEStepEntityNameOperationRoom;
    if (sender == self.addStepButton) {
        editStepController.stepNumber = [NSString stringWithFormat:@"Step %i", (int)(self.specManager.currentProcedure.operationRoom.steps.count + 1)];
        editStepController.stepText = @"";
    } else {
        PEOperationTableViewCell *cell = (PEOperationTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        editStepController.stepNumber = cell.labelStep.text;
        editStepController.stepText = cell.labelOperationRoomText.text;
        self.specManager.currentStep = self.sortedArrayWithPreprations[selectedIndexPath.row];
    }
    [self.navigationController pushViewController:editStepController animated:YES];
}

@end
