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
#import "UIImage+ImageWithJPGFile.h"

@interface PEEditAddDoctorTableViewCell() <UICollectionViewDataSource, UICollectionViewDelegate>

@property (strong, nonatomic) NSArray *arrayWithSpecObjects;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PEEditAddDoctorTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCellItemCell" bundle:nil] forCellWithReuseIdentifier:@"collectionViewInternalCell"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    self.collectionView.allowsMultipleSelection = YES;
    
    self.arrayWithSpecObjects = [[NSMutableArray alloc] init];
    [self initWithData];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arrayWithSpecObjects.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PECollectionViewCellItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewInternalCell" forIndexPath:indexPath];
    if (!cell) {
        cell =[[PECollectionViewCellItemCell alloc] init];
    }
    
    cell.activeImageViewWithLogo.image = [UIImage imageNamedFile:((Specialisation *)self.arrayWithSpecObjects[indexPath.row]).activeButtonPhotoName];
    cell.inactiveImageViewWithLogo.image = [UIImage imageNamedFile:((Specialisation *)self.arrayWithSpecObjects[indexPath.row]).inactiveButtonPhotoName];
    cell.labelNameOfSpec.text = ((Specialisation *)self.arrayWithSpecObjects[indexPath.row]).name;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellSelected:((Specialisation *)self.arrayWithSpecObjects[indexPath.row]).name];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate cellDeselected:((Specialisation *)self.arrayWithSpecObjects[indexPath.row]).name];
}


#pragma mark - Private

- (void)initWithData
{
    PEObjectDescription *searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.arrayWithSpecObjects = [PECoreDataManager getAllEntities:searchedObject];
    [self.arrayWithSpecObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString *o1 = ((Specialisation *)obj1).name;
        NSString *o2 = ((Specialisation *)obj2).name;
        return [o1 compare:o2];
    }];
}

- (void)selectAllSpecs
{
    for (int i = 0; i < self.arrayWithSpecObjects.count; i++) {
        Specialisation *spec = (Specialisation *)self.arrayWithSpecObjects[i];
        [self.delegate cellSelected:spec.name];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

@end
