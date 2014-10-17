//
//  PEProcedureListTableViewCell.m
//  Periop
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEProcedureListTableViewCell.h"

static CGFloat const PLTAnimationDuration = 0.2f;
static CGFloat const PLTMultiplier = 1.8f;
static NSString *const PLTSwipeLeftAnimationKey = @"swipeLeftKey";
static NSString *const PLTSwipeRightAnimationKey = @"swipeRightKey";

@interface PEProcedureListTableViewCell () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintRightForCustomView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *constraintLeftForCustomView;

@end

@implementation PEProcedureListTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [self initGestrudeRecognizer];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.constraintLeftForCustomView.constant = 0;
    self.constraintRightForCustomView.constant = 0;
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - IBActions

- (void)longTapPress:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan) {
        [self.delegate longPressRecognised:self];
    }
}

- (IBAction)deleteButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonDeleteActionProcedure:)]) {
        [self.delegate buttonDeleteActionProcedure:self];
    }
}

- (IBAction)swipeLeft:(id)sender
{
    if (self.customContentView.frame.origin.x < 0) {
        return;
    }
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.duration = PLTAnimationDuration;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGPoint startPosition = self.customContentView.layer.position;
    [values addObject:[NSValue valueWithCGPoint:startPosition]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * PLTMultiplier, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * 0.8, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y)]];
    position.keyTimes = @[@0, @0.6, @0.8, @1.0];
    position.values = values;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
    position.removedOnCompletion = NO;
    position.delegate = self;
    [self.customContentView.layer addAnimation:position forKey:PLTSwipeLeftAnimationKey];
    self.customContentView.layer.position = CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y);
    self.deleteButton.hidden = NO;
}

- (IBAction)swipeRight:(id)sender
{
    if (!self.customContentView.frame.origin.x) {
        return;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = PLTAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGPoint:self.customContentView.layer.position];
    CGPoint toPoint = self.customContentView.layer.position;
    toPoint.x = self.customContentView.frame.size.width / 2;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.customContentView.layer addAnimation:animation forKey:PLTSwipeRightAnimationKey];
    self.customContentView.layer.position = toPoint;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidSwipedInProcedure:)]) {
        [self.delegate cellDidSwipedInProcedure:self];
    }
    self.constraintRightForCustomView.constant = 0;
    self.constraintLeftForCustomView.constant = 0;
}

#pragma mark - Animation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.customContentView.layer animationForKey:PLTSwipeLeftAnimationKey]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellDidSwipedInProcedure:)]) {
            [self.delegate cellDidSwipedOutProcedure:self];
        }
        [self.customContentView.layer removeAnimationForKey:PLTSwipeLeftAnimationKey];
        self.constraintRightForCustomView.constant = CGRectGetWidth(self.deleteButton.frame);
        self.constraintLeftForCustomView.constant = -CGRectGetWidth(self.deleteButton.frame);
    } else if (anim ==[self.customContentView.layer animationForKey:PLTSwipeRightAnimationKey]) {
        [self.customContentView.layer removeAnimationForKey:PLTSwipeRightAnimationKey];
        self.deleteButton.hidden = YES;
    }
}

#pragma mark - PEProcedureListTableViewCellGestrudeDelegate

- (void)setCellSwiped
{
    self.deleteButton.hidden = NO;
    self.constraintRightForCustomView.constant = CGRectGetWidth(self.deleteButton.frame);
    self.constraintLeftForCustomView.constant = -CGRectGetWidth(self.deleteButton.frame);
}

#pragma mark - Private

- (void)initGestrudeRecognizer
{
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapPress:)];
    longPressRecognizer.minimumPressDuration = 0.5;
    [self.labelProcedureName addGestureRecognizer:longPressRecognizer];
    
    UISwipeGestureRecognizer *leftGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    leftGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    
    UISwipeGestureRecognizer *rightGestrudeRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    rightGestrudeRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self addGestureRecognizer:rightGestrudeRecognizer];
    [self addGestureRecognizer:leftGestrudeRecognizer];
}


@end
