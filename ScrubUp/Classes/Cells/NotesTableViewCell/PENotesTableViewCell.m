//
//  PENotesTableViewCell.m
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PENotesTableViewCell.h"

@interface PENotesTableViewCell()

@end

@implementation PENotesTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.timestampLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:13.5f];
    self.label.font = [UIFont fontWithName:FONT_MuseoSans300 size:12.5f];
}

#pragma mark - IBActions

- (IBAction)photoButton:(id)sender
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
