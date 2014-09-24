//
//  PEEquipmentCategoryTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEquipmentCategoryTableViewCell.h"


@interface PEEquipmentCategoryTableViewCell() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteOutlet;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

@implementation PEEquipmentCategoryTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initGestrudeRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.checkButton setSelected:NO];
    self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
}

#pragma mark - Gestrude

- (void)initGestrudeRecognizer
{
    UISwipeGestureRecognizer * leftGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer * rightGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightGestrudeRecognizer];
    [self addGestureRecognizer:leftGestrudeRecognizer];
}

- (IBAction)swipeLeft:(id)sender
{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width*2.8, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^ {
            self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
        } completion:^(BOOL finished) {
            self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
            //call to delegate method - add cell to list of openes cells
            [self.delegate cellDidSwipedOut:self];
        }];
    }];
}

- (IBAction)swipeRight:(id)sender
{
    [UIView animateWithDuration:0 animations:^ {
        self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
    } completion:^(BOOL finished) {
        [self.delegate cellDidSwipedIn:self];
    }];
    
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - IBActions

- (IBAction)checkButton:(id)sender
{
    if (![self.checkButton isSelected]) {
        self.checkButton.selected = YES;
        [self.delegate cellChecked:self];
    } else {
        self.checkButton.selected = NO;
        [self.delegate cellUnchecked:self];
    }
}

- (IBAction)deleteButton:(id)sender
{
    [self.delegate buttonDeleteAction:self];
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate & panRecognizer

- (void) setCellSwiped
{
    self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
}

-(void)cellSetChecked
{
    self.checkButton.selected = YES;
}

@end
