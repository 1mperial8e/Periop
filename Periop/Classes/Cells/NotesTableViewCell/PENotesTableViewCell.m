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
