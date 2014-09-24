//
//  PEEditAddDoctorTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEditAddDoctorTableViewCell.h"
#import "PECollectionViewCellItemCell.h"
#import "PEAddEditDoctorViewController.h"
#import "PECoreDataManager.h"
#import "PEObjectDescription.h"
#import "Specialisation.h"

@interface PEEditAddDoctorTableViewCell() < UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray * arrayWithSpecObjects;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;

@end

@implementation PEEditAddDoctorTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCellItemCell" bundle:nil] forCellWithReuseIdentifier:@"collectionViewInternalCell"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.allowsMultipleSelection = YES;
    
    self.arrayWithSpecObjects = [[NSMutableArray alloc] init];
    [self initWithData];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayWithSpecObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PECollectionViewCellItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewInternalCell" forIndexPath:indexPath];
    if (!cell) {
        cell =[[PECollectionViewCellItemCell alloc] init];
    }
    
    cell.activeImageViewWithLogo.image = [UIImage imageNamed:((Specialisation*)self.arrayWithSpecObjects[indexPath.row]).activeButtonPhotoName];
    cell.inactiveImageViewWithLogo.image = [UIImage imageNamed:((Specialisation*)self.arrayWithSpecObjects[indexPath.row]).inactiveButtonPhotoName];
    cell.labelNameOfSpec.text = ((Specialisation*)self.arrayWithSpecObjects[indexPath.row]).name;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellSelected:((Specialisation*)self.arrayWithSpecObjects[indexPath.row]).name];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellUnselected:((Specialisation*)self.arrayWithSpecObjects[indexPath.row]).name];
}

#pragma mark - Private

- (void) initWithData
{
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.arrayWithSpecObjects = [PECoreDataManager getAllEntities:searchedObject];
}

@end
