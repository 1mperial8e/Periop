//
//  PEDoctorsViewTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//


@protocol PEDoctorsViewTableViewCellDelegate

@optional

- (void)buttonDeleteAction:(UITableViewCell *)cell;
- (void)cellDidSwipedIn: (UITableViewCell *)cell;
- (void)cellDidSwipedOut:(UITableViewCell *)cell;

@end


@interface PEDoctorsViewTableViewCell : UITableViewCell <PEDoctorsViewTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewDoctorsNameView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

@property (weak, nonatomic) id <PEDoctorsViewTableViewCellDelegate> delegate;

- (void)setCellSwiped;

@end
