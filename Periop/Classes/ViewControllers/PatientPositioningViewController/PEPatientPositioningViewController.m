//
//  PEPatientPositioningViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPatientPositioningViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEPatientPostioningPreviewCollectionView.h"
#import "PEMediaSelect.h"
#import "Procedure.h"
#import "PESpecialisationManager.h"
#import "PEAlbumViewController.h"
#import "Photo.h"
#import "PatientPostioning.h"
#import <QuartzCore/QuartzCore.h>
#import "PEViewPhotoViewController.h"

@interface PEPatientPositioningViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *postedCollectionView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (weak, nonatomic) IBOutlet UICollectionView *previewCollectionView;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSMutableArray * sortedArrayWithPhotos;

@end

@implementation PEPatientPositioningViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.postedCollectionView registerNib:[UINib nibWithNibName:@"PEOperationRoomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"OperationRoomViewCell"];
    [self.previewCollectionView registerNib:[UINib nibWithNibName:@"PatientPostioningPreviewCell" bundle:nil] forCellWithReuseIdentifier:@"PatientCell"];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.numberOfLines = 0;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
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
    
    self.previewCollectionView.delegate = self;
    self.previewCollectionView.dataSource = self;
    
    self.previewCollectionView.layer.borderWidth = 0.0f;
    self.postedCollectionView.layer.borderWidth = 0.0f;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    [[self.view viewWithTag:35] removeFromSuperview];
    self.sortedArrayWithPhotos = [self sortedArrayWithPhotos:[self.specManager.currentProcedure.patientPostioning.photo allObjects]];
    self.pageControll.numberOfPages = self.sortedArrayWithPhotos.count;
    [self.postedCollectionView reloadData];
    [self.previewCollectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

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
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
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
    if ([collectionView isEqual:self.postedCollectionView]) {
        PEOperationRoomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperationRoomViewCell" forIndexPath:indexPath];
        if (self.sortedArrayWithPhotos.count>0) {
            cell.operationRoomImage.image = [UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData];
            self.pageControll.currentPage = [indexPath row];
        } else {
            cell.operationRoomImage.image = [UIImage imageNamed:@"Place_Holder"];
        }
        return cell;
    } else {
        PEPatientPostioningPreviewCollectionView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PatientCell" forIndexPath:indexPath];
        cell.backgroundColor = [UIColor blueColor];
        if (self.sortedArrayWithPhotos.count>0) {
            cell.image.image = [UIImage imageWithData:((Photo*)self.sortedArrayWithPhotos[indexPath.row]).photoData];
        } else {
            cell.image.image = [UIImage imageNamed:@"Place_Holder"];
        }
        return cell;
    }
}


- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PEViewPhotoViewController * viewPhotoControleller = [[PEViewPhotoViewController alloc] initWithNibName:@"PEViewPhotoViewController" bundle:nil];
    if (self.sortedArrayWithPhotos.count >0) {
        viewPhotoControleller.photoToShow = (Photo*)self.sortedArrayWithPhotos[indexPath.row];
    }
    [self.navigationController pushViewController:viewPhotoControleller animated:YES];
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

@end
