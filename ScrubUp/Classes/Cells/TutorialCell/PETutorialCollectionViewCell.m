//
//  PESpecialisationCollectionViewCell.m
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PETutorialCollectionViewCell.h"

@implementation PETutorialCollectionViewCell

#pragma mark - LifeCycle

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.getStartedButton.hidden = YES;
}

#pragma mark - IBActions

- (IBAction)getStartedButtonPress:(id)sender
{
    [self.delegate getStartedButtonPress];
}


@end
