//
//  PEEquipmentCategoryTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PEEquipmentCategoryTableViewCellDelegate <NSObject>

@optional
//delegated method - add more if you want to use for few buttons
- (void)buttonAction;
//methods for storing current state of cells
- (void) cellDidOpen:(UITableViewCell*)cell;
- (void) cellDidClose:(UITableViewCell *)cell;

@end

@interface PEEquipmentCategoryTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *equipmentNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewWithContent;

//property for delegate
@property (weak, nonatomic) id <PEEquipmentCategoryTableViewCellDelegate> delegate;
//mathod that allow delegate to change state of cell
- (void)openCell;


@end
