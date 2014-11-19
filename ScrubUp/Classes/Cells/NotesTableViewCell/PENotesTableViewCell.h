//
//  PENotesTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PENotesTableViewCellDelegate <NSObject>

@required
- (void)addPhotoButtonPress:(UITableViewCell *)cell;
- (void)deleteNotesButtonPress:(UITableViewCell *)cell;
- (void)editNoteButtonPress:(UITableViewCell *)cell;

@end

@interface PENotesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *timestampLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *cornerLabel;
@property (weak, nonatomic) IBOutlet UIButton *photoButton;

@property (strong, nonatomic) id <PENotesTableViewCellDelegate> delegate;

@end
