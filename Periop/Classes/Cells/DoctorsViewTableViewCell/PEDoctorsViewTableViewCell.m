//
//  PEDoctorsViewTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDoctorsViewTableViewCell.h"

@interface PEDoctorsViewTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation PEDoctorsViewTableViewCell 

#pragma mark LifeCycle

- (void)awakeFromNib
{
    [self initGestrudeRecognizer];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.viewDoctorsNameView.frame = CGRectMake(0, 0, self.viewDoctorsNameView.frame.size.width, self.viewDoctorsNameView.frame.size.height);
}

#pragma mark - IBActions

- (IBAction)deleteDoctorButtons:(id)sender
{
    [self.delegate buttonDeleteAction:self];
}

#pragma mark - Gestrude

- (void)initGestrudeRecognizer
{
    UISwipeGestureRecognizer *leftGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer *rightGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:rightGestrudeRecognizer];
    [self addGestureRecognizer:leftGestrudeRecognizer];
}

- (IBAction)swipeLeft:(id)sender
{
    PEDoctorsViewTableViewCell __weak *weakSelf = self;
    [UIView animateWithDuration:0.2 animations:^ {
    weakSelf.viewDoctorsNameView.frame = CGRectMake(-weakSelf.deleteButton.frame.size.width *2.8, 0, weakSelf.viewDoctorsNameView.frame.size.width, weakSelf.viewDoctorsNameView.frame.size.height);
    } completion:^(BOOL finished) {
    [UIView animateWithDuration:0.2 animations:^ {
            weakSelf.viewDoctorsNameView.frame = CGRectMake(-weakSelf.deleteButton.frame.size.width, 0, weakSelf.viewDoctorsNameView.frame.size.width, weakSelf.viewDoctorsNameView.frame.size.height);
        } completion:^(BOOL finished) {
            weakSelf.viewDoctorsNameView.frame = CGRectMake(-weakSelf.deleteButton.frame.size.width, 0, weakSelf.viewDoctorsNameView.frame.size.width, weakSelf.viewDoctorsNameView.frame.size.height);
            [weakSelf.delegate cellDidSwipedOut:weakSelf];
        }];
    }];
}

- (IBAction)swipeRight:(id)sender
{
   [UIView animateWithDuration:0 animations:^ {
        self.viewDoctorsNameView.frame = CGRectMake(0, 0, self.viewDoctorsNameView.frame.size.width, self.viewDoctorsNameView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.delegate cellDidSwipedIn:self];
    }];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - PEDoctorsViewTableViewCellDelegate

- (void)setCellSwiped
{
    self.viewDoctorsNameView.frame = CGRectMake(-self.deleteButton.frame.size.width, 0, self.viewDoctorsNameView.frame.size.width, self.viewDoctorsNameView.frame.size.height);
}

@end
