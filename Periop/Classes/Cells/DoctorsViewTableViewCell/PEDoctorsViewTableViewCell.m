//
//  PEDoctorsViewTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//
static NSString *const DVTVCAnimationSwipeLeft = @"swipeLeft";
static CGFloat const DVTVAnimationDuration = 0.2f;
static CGFloat const DVTVMultiplier = 1.8f;

#import "PEDoctorsViewTableViewCell.h"

@interface PEDoctorsViewTableViewCell ()

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;

@end

@implementation PEDoctorsViewTableViewCell 

#pragma mark LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initGestrudeRecognizer];
    self.deleteButton.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
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
    if (self.viewDoctorsNameView.frame.origin.x < 0) {
        return;
    }
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.duration = DVTVAnimationDuration;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGPoint startPosition = self.viewDoctorsNameView.layer.position;
    [values addObject:[NSValue valueWithCGPoint:startPosition]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * DVTVMultiplier, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width * 0.8, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y)]];
    position.keyTimes = @[@0, @0.6, @0.8, @1.0];
    position.values = values;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
    position.removedOnCompletion = NO;
    position.delegate = self;
    [self.viewDoctorsNameView.layer addAnimation:position forKey:DVTVCAnimationSwipeLeft];
    self.viewDoctorsNameView.layer.position = CGPointMake(startPosition.x - self.deleteButton.frame.size.width, startPosition.y);
}

- (IBAction)swipeRight:(id)sender
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = DVTVAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGPoint:self.viewDoctorsNameView.layer.position];
    CGPoint toPoint = self.viewDoctorsNameView.layer.position;
    toPoint.x = self.viewDoctorsNameView.frame.size.width / 2;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.removedOnCompletion = YES;
    [self.viewDoctorsNameView.layer addAnimation:animation forKey:nil];
    self.viewDoctorsNameView.layer.position = toPoint;
    [self.delegate cellDidSwipedIn:self];
}

#pragma mark - Animation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.viewDoctorsNameView.layer animationForKey:DVTVCAnimationSwipeLeft]) {
        [self.delegate cellDidSwipedOut:self];
        [self.viewDoctorsNameView.layer removeAnimationForKey:DVTVCAnimationSwipeLeft];
    }
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
