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
#import "PEPreparationTableViewCell.h"
#import "Steps.h"
#import "PESpecialisationManager.h"
#import "OperationRoom.h"
#import "Procedure.h"
#import "PEAlbumViewController.h"
#import "Photo.h"
#import <QuartzCore/QuartzCore.h>

@interface PEOperationRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *operationWithPhotoButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSArray * sortedArrayWithPreprations;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithPhotos;

@end

@implementation PEOperationRoomViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.layer.borderWidth = 0.0f;
    self.tableView.layer.borderWidth = 0.0f;

    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.sortedArrayWithPreprations =[self sortedArrayWithPreparationSteps:[self.specManager.currentProcedure.operationRoom.steps allObjects]];

    [self.collectionView registerNib:[UINib nibWithNibName:@"PEOperationRoomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"OperationRoomViewCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEPreparationTableViewCell" bundle:nil] forCellReuseIdentifier:@"preparationCell"];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operation Room"];
    
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
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[self.view viewWithTag:35] removeFromSuperview];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.operationRoom.photo allObjects]];
    self.pageController.numberOfPages = self.sortedArrayWithPhotos.count;
    [self.collectionView reloadData];
    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.sortedArrayWithPhotos.count>0) {
        return self.sortedArrayWithPhotos.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEOperationRoomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperationRoomViewCell" forIndexPath:indexPath];
    if (self.sortedArrayWithPhotos.count >0) {
        cell.operationRoomImage.image = [UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData];
    } else {
        cell.operationRoomImage.image = [UIImage imageNamed:@"Place_Holder"];
    }
    
    self.pageController.currentPage = [indexPath row];
    return cell;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return  [self.specManager.currentProcedure.operationRoom.steps count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PEPreparationTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"preparationCell"];
    if (!cell){
        cell = [[PEPreparationTableViewCell alloc] init];
    }
    cell = [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

#pragma mark - DynamicHeightOfCell

- (PEPreparationTableViewCell *)configureCell: (PEPreparationTableViewCell*)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.labelStep.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepName;
    cell.labelPreparationText.text = ((Steps*)(self.sortedArrayWithPreprations[indexPath.row])).stepDescription;
    return cell;
}

- (CGFloat)heightForBasicCellAtIndexPath: (NSIndexPath*) indexPath
{
    static PEPreparationTableViewCell * sizingCell = nil;
    static dispatch_once_t  token;
    dispatch_once(&token, ^ {
        sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"preparationCell"];
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
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
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
    NSLog(@"camera Photo from Op");
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma marks - Private

- (NSArray * )sortedArrayWithPreparationSteps: (NSArray*)arrayToSort
{
    NSArray * sortedArray;
    sortedArray = [arrayToSort sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * firstObject = [(Steps*)obj1 stepName];
        NSString * secondObject = [(Steps*)obj2 stepName];
        return [firstObject compare:secondObject];
    }];
    return sortedArray;
}

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

@end
