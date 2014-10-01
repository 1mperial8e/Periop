//
//  PENotesTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PENotesTableViewCell.h"

@interface PENotesTableViewCell()

@end

@implementation PENotesTableViewCell

#pragma mark - LifeCycle

- (void) awakeFromNib
{
    self.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:14.5f];
    self.label.font = [UIFont fontWithName:FONT_MuseoSans300 size:12.5f];
}

#pragma mark - IBActions

- (IBAction)photButton:(id)sender
{
    [self.delegate addPhotoButtonPress:self];
}

- (IBAction)deleteButton:(id)sender
{
    [self.delegate deleteNotesButtonPress:self];
}

- (IBAction)editButton:(id)sender
{
    [self.delegate editNoteButtonPress:self];
}
@end
