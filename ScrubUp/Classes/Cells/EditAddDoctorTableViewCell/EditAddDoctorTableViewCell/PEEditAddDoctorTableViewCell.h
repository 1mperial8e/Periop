//
//  PEEditAddDoctorTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEEditAddDoctorTableViewCellDelegate

@required
- (void)cellSelected:(NSString *)specialisationName;
- (void)cellDeselected:(NSString *)specialisationName;

@end

@interface PEEditAddDoctorTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) id <PEEditAddDoctorTableViewCellDelegate> delegate;

- (void)selectAllSpecs;

@end
