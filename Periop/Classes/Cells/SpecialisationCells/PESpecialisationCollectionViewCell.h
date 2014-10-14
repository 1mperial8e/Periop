//
//  PESpecialisationCollectionViewCell.h
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PESpecialisationCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *specialisationIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;

@property (copy, nonatomic) NSString *specName;
@property (copy, nonatomic) NSString *productIdentifier;

@end
