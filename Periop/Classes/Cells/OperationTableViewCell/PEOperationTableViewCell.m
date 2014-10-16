//
//  PEOperationTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/30/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEOperationTableViewCell.h"

static CGFloat const OTVCAnimationDuraton = 0.2f;
static CGFloat const OTVCMultiplier = 1.8f;
static NSString *const OTVCAnimationKeyLeft = @"swipeLeft";
static NSString *const OTVCAnimationKeyRight = @"swipeRight";

@interface PEOperationTableViewCell ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXRightSpace;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewXLeftSpace;

@end

@implementation PEOperationTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.labelStep.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
    self.labelOperationRoomText.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
    [self initGestureRecognizers];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.contentViewXRightSpace.constant = 0;
    self.contentViewXLeftSpace.constant = 0;
}


#pragma mark - IBActions

- (IBAction)deleteButton:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(buttonDeleteAction:)]) {
        [self.delegate buttonDeleteAction:self];
    }
}

- (void)swipeLeft:(id)sender
{
    if (self.customContentView.frame.origin.x < 0 || self.selected) {
        return;
    }
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.duration = OTVCAnimationDuraton;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGPoint startPosition = self.customContentView.layer.position;
    [values addObject:[NSValue valueWithCGPoint:startPosition]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * OTVCMultiplier, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * 0.8, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y)]];
    position.keyTimes = @[@0, @0.6, @0.8, @1];
    position.values = values;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
    position.removedOnCompletion = NO;
    position.delegate = self;
    [self.customContentView.layer addAnimation:position forKey:OTVCAnimationKeyLeft];
    self.customContentView.layer.position = CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y);
    self.deleteButton.hidden = NO;
}

- (void)swipeRight:(id)sender
{
    if (!self.customContentView.frame.origin.x) {
        return;
    }
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = OTVCAnimationDuraton;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGPoint:self.customContentView.layer.position];
    CGPoint toPoint = self.customContentView.layer.position;
    toPoint.x = self.customContentView.frame.size.width / 2;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.customContentView.layer addAnimation:animation forKey:OTVCAnimationKeyRight];
    self.customContentView.layer.position = toPoint;
    if (self.delegate && [self.delegate respondsToSelector:@selector(cellSwipedIn:)]) {
        [self.delegate cellSwipedIn:self];
    }
    self.contentViewXRightSpace.constant = 0;
    self.contentViewXLeftSpace.constant = 0;
}

#pragma mark - Animation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.customContentView.layer animationForKey:OTVCAnimationKeyLeft]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(cellSwipedOut:)]) {
            [self.delegate cellSwipedOut:self];
        }
        [self.customContentView.layer removeAnimationForKey:OTVCAnimationKeyLeft];
        self.contentViewXRightSpace.constant = CGRectGetWidth(self.deleteButton.frame);
        self.contentViewXLeftSpace.constant = -CGRectGetWidth(self.deleteButton.frame);
    } else if (anim == [self.customContentView.layer animationForKey:OTVCAnimationKeyRight]) {
        [self.customContentView.layer removeAnimationForKey:OTVCAnimationKeyRight];
        self.deleteButton.hidden = YES;
    }
}

#pragma mark - Private

- (void)initGestureRecognizers
{
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.customContentView addGestureRecognizer:swipeLeft];
    
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.customContentView addGestureRecognizer:swipeRight];
}

- (void)setCellSwiped
{
    self.deleteButton.hidden = NO;
    self.contentViewXRightSpace.constant = CGRectGetWidth(self.deleteButton.frame);
    self.contentViewXLeftSpace.constant = -CGRectGetWidth(self.deleteButton.frame);
}

@end
