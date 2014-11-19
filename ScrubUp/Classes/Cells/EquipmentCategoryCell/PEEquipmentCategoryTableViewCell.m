//
//  PEEquipmentCategoryTableViewCell.m
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const ECAnimationSwipeLeft = @"swipeLeft";
static CGFloat const ECAnimationDuration = 0.2f;
static CGFloat const ECMultiplier = 1.8f;

#import "PEEquipmentCategoryTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface PEEquipmentCategoryTableViewCell() <UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteOutlet;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@end

@implementation PEEquipmentCategoryTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initGestrureRecognizer];
    self.buttonDeleteOutlet.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
    self.equipmentNameLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:16.5f];
    self.equipmentNameLabel.textColor = UIColorFromRGB(0x1C1C1C);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.checkButton setSelected:NO];
    self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
}

#pragma mark - Gestrure

- (void)initGestrureRecognizer
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
    if (self.viewWithContent.frame.origin.x < 0) {
        return;
    }
    CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    position.duration = ECAnimationDuration;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    CGPoint startPosition = self.viewWithContent.layer.position;
    [values addObject:[NSValue valueWithCGPoint:startPosition]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.buttonDeleteOutlet.frame.size.width * ECMultiplier, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.buttonDeleteOutlet.frame.size.width * 0.8, startPosition.y)]];
    [values addObject:[NSValue valueWithCGPoint:CGPointMake(startPosition.x - self.buttonDeleteOutlet.frame.size.width, startPosition.y)]];
    position.keyTimes = @[@0, @0.6, @0.8, @1];
    position.values = values;
    position.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
    position.removedOnCompletion = NO;
    position.delegate = self;
    [self.viewWithContent.layer addAnimation:position forKey:ECAnimationSwipeLeft];
    self.viewWithContent.layer.position = CGPointMake(startPosition.x - self.buttonDeleteOutlet.frame.size.width, startPosition.y);
}

- (IBAction)swipeRight:(id)sender
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = ECAnimationDuration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSValue valueWithCGPoint:self.viewWithContent.layer.position];
    CGPoint toPoint = self.viewWithContent.layer.position;
    toPoint.x = self.viewWithContent.frame.size.width / 2;
    animation.toValue = [NSValue valueWithCGPoint:toPoint];
    animation.removedOnCompletion = YES;
    [self.viewWithContent.layer addAnimation:animation forKey:nil];
    self.viewWithContent.layer.position = toPoint;
    [self.delegate cellDidSwipedIn:self];
}

#pragma mark - Animation

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.viewWithContent.layer animationForKey:ECAnimationSwipeLeft]) {
        [self.delegate cellDidSwipedOut:self];
        [self.viewWithContent.layer removeAnimationForKey:ECAnimationSwipeLeft];
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
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

- (void)setCellSwiped
{
    self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
}

-(void)cellSetChecked
{
    self.checkButton.selected = YES;
}

@end
