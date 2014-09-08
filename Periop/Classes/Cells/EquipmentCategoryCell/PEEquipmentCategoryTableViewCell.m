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

@end

@implementation PEEquipmentCategoryTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [self initGestrudeRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//fixing issue with not remembeering of cell's state
//close all cells during flipping tableView
- (void)prepareForReuse{
    [super prepareForReuse];
    //close all cells before showing
    self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);

   }
#pragma mark - Gestrude

- (void)initGestrudeRecognizer{
    UISwipeGestureRecognizer * leftGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    UISwipeGestureRecognizer * rightGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self addGestureRecognizer:rightGestrudeRecognizer];
    [self addGestureRecognizer:leftGestrudeRecognizer];
}

- (IBAction)swipeLeft:(id)sender{
    [UIView animateWithDuration:0.2 animations:^{
        self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width*2.8, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
        } completion:^(BOOL finished) {
            self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
            //call to delegate method - add cell to list of openes cells
            [self.delegate cellDidSwipedOut:self];
        }];
    }];
}

- (IBAction)swipeRight:(id)sender{
    [UIView animateWithDuration:0 animations:^{
        self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
    } completion:^(BOOL finished) {
        //call to delegate remove objects from list of opened cells
        [self.delegate cellDidSwipedIn:self];
    }];
    
}
#pragma mark - UIGestureRecognizerDelegate

- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}

#pragma mark - IBActions

- (IBAction)checkButton:(id)sender {
}

- (IBAction)deleteButton:(id)sender {
    //PEEquipmentCategoryTableViewCellDelegate delegate usage
    [self.delegate buttonDeleteAction];
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate & panRecognizer
//this method must open cell if called
- (void) setCellSwiped{
    self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
}

@end
