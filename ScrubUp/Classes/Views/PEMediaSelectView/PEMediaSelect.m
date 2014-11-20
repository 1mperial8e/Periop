//
//  PEMediaSelect.m
//  ScrubUp
//
//  Created by Kirill on 9/12/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMediaSelect.h"

@implementation PEMediaSelect

#pragma mark - LifeCycle

- (void)setVisible:(BOOL)visible
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.2;
    animation.fromValue = visible ? @0 : @1;
    animation.toValue = visible ? @1 : @0;
    animation.delegate = self;
    animation.removedOnCompletion = visible;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [self.layer addAnimation:animation forKey:visible ? nil : @"remove"];
    self.layer.opacity = visible ? 1.0 : 0;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.layer animationForKey:@"remove"]) {
        [self.layer removeAnimationForKey:@"remove"];
        [self removeFromSuperview];
    }
}

@end
