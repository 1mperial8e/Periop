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

@interface PEPatientPositioningViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *postedCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (weak, nonatomic) IBOutlet UITableView *tableViewPatient;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithPhotos;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithPatientPositioning;

@end

@implementation PEPatientPositioningViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.postedCollectionView registerNib:[UINib nibWithNibName:@"PEOperationRoomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"OperationRoomViewCell"];
    [self.tableViewPatient registerNib:[UINib nibWithNibName:@"PEPatientPositioningTableViewCell" bundle:nil] forCellReuseIdentifier:@"patientPositioningStepsCell"];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.numberOfLines = 0;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    self.navigationBarLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0];
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Patient Postioning"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat: @"\n%@",((Procedure*)self.specManager.currentProcedure).name]];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    self.navigationBarLabel.attributedText = stringForLabelTop;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];

    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
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
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [[self.view viewWithTag:35] removeFromSuperview];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.patientPostioning.photo allObjects]];
    self.sortedArrayWithPatientPositioning = [self sortedArrayWithPatientPos:[self.specManager.currentProcedure.patientPostioning.steps allObjects]];
    self.pageControll.numberOfPages = self.sortedArrayWithPhotos.count;
    [self.postedCollectionView reloadData];
    [self.tableViewPatient reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma marks - IBActions

- (IBAction)operationWithPhotoButton:(id)sender
{
    CGRect size = self.view.bounds;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = size;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    NSLog(@"camera Photo from Op");
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = PatientPostioningViewController;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.specManager.currentProcedure.patientPostioning.steps allObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEPatientPositioningTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"patientPositioningStepsCell" forIndexPath:indexPath];
    if (!cell) {
        cell = [[PEPatientPositioningTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"patientPositioningStepsCell"];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma mark - DynamicHeightOfCell

- (PEPatientPositioningTableViewCell*)configureCell: (PEPatientPositioningTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.labelStepName.text = ((Steps*)self.sortedArrayWithPatientPositioning[indexPath.row]).stepName;
    cell.labelContent.text = ((Steps*)self.sortedArrayWithPatientPositioning[indexPath.row]).stepDescription;
    
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath: (NSIndexPath*) indexPath
{
    static PEPatientPositioningTableViewCell * sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableViewPatient dequeueReusableCellWithIdentifier:@"patientPositioningStepsCell"];
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
    PEOperationRoomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperationRoomViewCell" forIndexPath:indexPath];
    if (self.sortedArrayWithPhotos.count>0) {
        cell.operationRoomImage.image = [UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData];
        self.pageControll.currentPage = [indexPath row];
    } else {
        cell.operationRoomImage.image = [UIImage imageNamed:@"Place_Holder"];
    }
    return cell;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.sortedArrayWithPhotos.count >0 && [((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData hash]!= [[UIImage imageNamed:@"Place_Holder"] hash]) {
        PEViewPhotoViewController * viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
        if (self.sortedArrayWithPhotos.count >0) {
            viewPhotoControleller.photoToShow = (Photo*)self.sortedArrayWithPhotos[indexPath.row];
        }
        [self.navigationController pushViewController:viewPhotoControleller animated:YES];
    }
}

#pragma marks - Private

- (NSMutableArray *)sortedArrayWithPhotos: (NSArray*)arrayToSort
{
    NSArray * sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber * firstObject = [(Photo*)obj1 photoNumber];
        NSNumber *  secondObject = [(Photo*)obj2 photoNumber];
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

- (NSMutableArray*) sortedArrayWithPatientPos: (NSArray * ) arrayToSort
{
    NSArray * sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Steps*)obj1 stepName ];
        NSString *  secondObject = [(Steps*)obj2 stepName];
        return [firstObject compare:secondObject];
    }];
    return [NSMutableArray arrayWithArray:sortedArray];
}

@end
