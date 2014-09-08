//
//  PEEditAddDoctorTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEditAddDoctorTableViewCell.h"
#import "PECollectionViewCellItemCell.h"

@interface PEEditAddDoctorTableViewCell() <UICollectionViewDataSource, UICollectionViewDelegate>

@end


@implementation PEEditAddDoctorTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    // Initialization code
    [self.collectionView registerNib:[UINib nibWithNibName:@"CollectionViewCellItemCell" bundle:nil] forCellWithReuseIdentifier:@"collectionViewInternalCell"];
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 15;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PECollectionViewCellItemCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"collectionViewInternalCell" forIndexPath:indexPath];
    if (!cell){
        cell =[[PECollectionViewCellItemCell alloc] init];
    }

    return cell;
}

@end
