//
//  PEPreparationTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/18/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEPreparationTableViewCellDelegate <NSObject>

@required
- (void)buttonDeleteAction:(UITableViewCell *)cell;
- (void)cellSwipedOut:(UITableViewCell *)cell;
- (void)cellSwipedIn:(UITableViewCell *)cell;

@end

@interface PEPreparationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelStep;
@property (weak, nonatomic) IBOutlet UILabel *labelPreparationText;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *customContentView;

@property (weak, nonatomic) id <PEPreparationTableViewCellDelegate> delegate;

- (void)setCellSwiped;

@end
