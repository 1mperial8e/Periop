//
//  PEOperationRoomViewController.m
//  Periop
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

static NSString *const OROperationRoomCollectionViewCellNibName = @"PEOperationRoomCollectionViewCell";
static NSString *const OROperationRoomCollectionViewCellIdentifier = @"OperationRoomViewCell";
static NSString *const OROperationTableViewCellNibName = @"PEOperationTableViewCell";
static NSString *const OROperationTableViewCellIdentifier = @"operationTableViewCell";

static NSString *const ORImagePlaceHolder = @"Place_Holder";
static NSInteger const ORTagView = 35;

@interface PEOperationRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate, UIPageViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *operationWithPhotoButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *labelSteps;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSArray *sortedArrayWithPreprations;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithPhotos;

@property (strong, nonatomic) UIBarButtonItem *addStepButton;
@property (strong, nonatomic) UIBarButtonItem *editStepButton;

@end

@implementation PEOperationRoomViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.specManager = [PESpecialisationManager sharedManager];
    
    self.labelSteps.font = [UIFont fontWithName:FONT_MuseoSans700 size:17.5f];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.layer.borderWidth = 0.0f;
    self.tableView.layer.borderWidth = 0.0f;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.sortedArrayWithPreprations =[self sortedArrayWithPreparationSteps:[self.specManager.currentProcedure.operationRoom.steps allObjects]];

    [self.collectionView registerNib:[UINib nibWithNibName:OROperationRoomCollectionViewCellNibName bundle:nil] forCellWithReuseIdentifier:OROperationRoomCollectionViewCellIdentifier];
    
    [self.tableView registerNib:[UINib nibWithNibName:OROperationTableViewCellNibName bundle:nil] forCellReuseIdentifier:OROperationTableViewCellIdentifier];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    [self createBarButtons];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operation Room"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure *)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    ((PENavigationController *)self.navigationController).titleLabel.attributedText = stringForLabelTop;
    
    [(PEMediaSelect *)[self.view viewWithTag:ORTagView] setVisible:NO];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.operationRoom.photo allObjects]];
    self.pageController.numberOfPages = self.sortedArrayWithPhotos.count;
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sortedArrayWithPhotos.count && [[UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData] hash] != [[UIImage imageNamedFile:ORImagePlaceHolder] hash]) {
        PEViewPhotoViewController *viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        if (self.sortedArrayWithPhotos.count) {
            viewPhotoControleller.photoToShow = (Photo*)self.sortedArrayWithPhotos[indexPath.row];
        }
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
        cell.operationRoomImage.image = [UIImage imageWithData:((Photo *)self.sortedArrayWithPhotos[indexPath.row]).photoData];
    } else {
        cell.operationRoomImage.image = [UIImage imageNamedFile:ORImagePlaceHolder];
    }
    
    self.pageController.currentPage = [indexPath row];
    return cell;
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

- (PEOperationTableViewCell *)configureCell:(PEOperationTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.labelStep.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepName;
    cell.labelOperationRoomText.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepDescription;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath*) indexPath
{
    static PEOperationTableViewCell *sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:OROperationTableViewCellIdentifier];
    });
    [self configureCell:sizingCell atIndexPath:indexPath];
    
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
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

#pragma marks - Private

- (NSArray *)sortedArrayWithPreparationSteps: (NSArray*)arrayToSort
{
    NSArray *sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *firstObject = ((Steps*)obj1).stepName;
        NSString *secondObject = ((Steps*)obj2).stepName;
        return [firstObject compare:secondObject];
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
    PEAddEditStepViewControllerViewController *editStepController = [PEAddEditStepViewControllerViewController new];
    editStepController.entityName = PEStepEntityNameOperationRoom;
    if (sender == self.addStepButton) {
        editStepController.stepNumber = [NSString stringWithFormat:@"Step %i", (int)(self.specManager.currentProcedure.operationRoom.steps.count + 1)];
        editStepController.stepText = @"";
    } else {
        PEOperationTableViewCell *cell = (PEOperationTableViewCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        editStepController.stepNumber = cell.labelStep.text;
        editStepController.stepText = cell.labelOperationRoomText.text;
    }
    [self.navigationController pushViewController:editStepController animated:YES];
}

@end
