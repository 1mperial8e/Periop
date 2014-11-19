//
//  PEProcedureListTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEProcedureListTableViewCellGestrudeDelegate  <NSObject>

@required

- (void)longPressRecognised:(UITableViewCell *)cell;

- (void)buttonDeleteActionProcedure:(UITableViewCell *)cell;
- (void)cellDidSwipedInProcedure:(UITableViewCell *)cell;
- (void)cellDidSwipedOutProcedure:(UITableViewCell *)cell;

@end

@interface PEProcedureListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelProcedureName;
@property (weak, nonatomic) IBOutlet UIView *customContentView;
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@property (weak, nonatomic) id <PEProcedureListTableViewCellGestrudeDelegate> delegate;

- (void)setCellSwiped;

@end
