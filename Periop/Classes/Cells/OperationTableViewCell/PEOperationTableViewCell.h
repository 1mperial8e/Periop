//
//  PEOperationTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/30/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEOperationTableViewCellDelegate <NSObject>

@required
- (void)buttonDeleteAction:(UITableViewCell *)cell;
- (void)cellSwipedOut:(UITableViewCell *)cell;
- (void)cellSwipedIn:(UITableViewCell *)cell;

@end

@interface PEOperationTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelStep;
@property (weak, nonatomic) IBOutlet UILabel *labelOperationRoomText;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *customContentView;

@property (weak, nonatomic) id <PEOperationTableViewCellDelegate> delegate;

- (void)setCellSwiped;

@end
