//
//  PEProcedureListTableViewCell.m
//  Periop
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEProcedureListTableViewCell.h"

@implementation PEProcedureListTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapPress:)];
    longPressRecognizer.minimumPressDuration = 0.5;
    [self.labelProcedureName addGestureRecognizer:longPressRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - IBActions

- (void)longTapPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];
        animation.duration = 0.15f;
        animation.values = @[@1, @1.3, @1.2];
        animation.keyTimes = @[@0, @0.5, @1];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        animation.removedOnCompletion = NO;
        animation.delegate = self;
        [self.textLabel.layer addAnimation:animation forKey:@"bounce"];
    }
}

#pragma mark - Animations Delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.textLabel.layer animationForKey:@"bounce"]) {
        [self.textLabel.layer removeAnimationForKey:@"bounce"];
        [self.delegate longPressRecognised:self];
    }
}

@end
