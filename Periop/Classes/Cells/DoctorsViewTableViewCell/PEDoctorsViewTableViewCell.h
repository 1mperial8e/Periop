//
//  PEDoctorsViewTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PEDoctorsViewTableViewCellDelegate

@optional
//buttonAction
- (void)buttonDeleteAction:(UITableViewCell*)cell;

//method for closing cell with swipe
- (void)cellDidSwipedIn: (UITableViewCell*)cell;
//method for opening cell with swipe
- (void)cellDidSwipedOut:(UITableViewCell *)cell;

@end


@interface PEDoctorsViewTableViewCell : UITableViewCell <PEDoctorsViewTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UILabel *doctorNameLabel;
@property (weak, nonatomic) IBOutlet UIView *viewDoctorsNameView;
@property (weak, nonatomic) IBOutlet UIButton *buttonDelete;

@property (strong, nonatomic) id <PEDoctorsViewTableViewCellDelegate> delegate;
//method for protocol PEDoctorsViewTableViewCellDelegate
- (void)setCellSwiped;

@end
