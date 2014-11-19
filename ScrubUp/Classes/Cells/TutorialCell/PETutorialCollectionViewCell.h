//
//  PESpecialisationCollectionViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PETutorialCollectionViewCellDelegate

@required
- (void)getStartedButtonPress;

@end

@interface PETutorialCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIButton *getStartedButton;

@property (strong, nonatomic) id <PETutorialCollectionViewCellDelegate> delegate;

@end
