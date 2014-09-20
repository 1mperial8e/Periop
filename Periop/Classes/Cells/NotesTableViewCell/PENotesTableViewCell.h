//
//  PENotesTableViewCell.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PENotesTableViewCellDelegate <NSObject>

@required
- (void)addPhotoButtonPress:(UITableViewCell*)cell;
- (void)deleteNotesButtonPress:(UITableViewCell*)cell;
- (void)editNoteButtonPress:(UITableViewCell*)cell;

@end

@interface PENotesTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *label;
@property (weak, nonatomic) IBOutlet UILabel *cornerLabel;

@property (strong, nonatomic) id <PENotesTableViewCellDelegate> delegate;

@end
