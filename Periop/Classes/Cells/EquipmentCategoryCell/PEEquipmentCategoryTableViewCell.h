//
//  PEEquipmentCategoryTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEEquipmentCategoryTableViewCellDelegate <NSObject>

@required

- (void)buttonDeleteAction:(UITableViewCell *)cell;

- (void)cellDidSwipedIn:(UITableViewCell *)cell;
- (void)cellDidSwipedOut:(UITableViewCell *)cell;

- (void)cellChecked:(UITableViewCell *)cell;
- (void)cellUnchecked:(UITableViewCell *)cell;

@end

@interface PEEquipmentCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *equipmentNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewWithContent;

@property (strong, nonatomic) NSDate *createdDate;

@property (weak, nonatomic) id <PEEquipmentCategoryTableViewCellDelegate> delegate;

- (void)setCellSwiped;
- (void)cellSetChecked;

@end
