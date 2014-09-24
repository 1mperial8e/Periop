//
//  PEEquipmentCategoryTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PEEquipmentCategoryTableViewCellDelegate <NSObject>

@required
//buttonAction
- (void)buttonDeleteAction:(UITableViewCell*)cell;

- (void)cellDidSwipedIn:(UITableViewCell*)cell;
- (void)cellDidSwipedOut:(UITableViewCell *)cell;

- (void)cellChecked:(UITableViewCell*)cell;
- (void)cellUnchecked:(UITableViewCell*)cell;

@end

@interface PEEquipmentCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *equipmentNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewWithContent;

//property for delegate
@property (weak, nonatomic) id <PEEquipmentCategoryTableViewCellDelegate> delegate;
//method that allow delegate to change state of cell
- (void)setCellSwiped;
- (void)cellSetChecked;

@end
