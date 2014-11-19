//
//  PEPatientPositioningTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/29/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEPatientPositioningTableViewCellDelegate <NSObject>

@required
- (void)buttonDeleteAction:(UITableViewCell *)cell;
- (void)cellSwipedOut:(UITableViewCell *)cell;
- (void)cellSwipedIn:(UITableViewCell *)cell;

@end

@interface PEPatientPositioningTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelStepName;
@property (weak, nonatomic) IBOutlet UILabel *labelContent;

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (weak, nonatomic) IBOutlet UIView *customContentView;

@property (weak, nonatomic) id <PEPatientPositioningTableViewCellDelegate> delegate;

- (void)setCellSwiped;

@end
