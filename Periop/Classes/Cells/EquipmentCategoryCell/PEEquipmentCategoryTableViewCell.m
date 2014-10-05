//
//  PEEquipmentCategoryTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const ECAnimationSwipeLeft = @"swipeLeft";
static NSString *const ECAnimationKeyPath = @"transform.translation.x";
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
    CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:ECAnimationKeyPath];
    translation.duration = ECAnimationDuration;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [values addObject:[NSNumber numberWithFloat:0.0f]];
    [values addObject:[NSNumber numberWithFloat:-self.buttonDeleteOutlet.frame.size.width * ECMultiplier]];
    translation.values = values;
    NSMutableArray *timingFunction = [[NSMutableArray alloc] init];
    [timingFunction addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    translation.timingFunctions = timingFunction;
    translation.removedOnCompletion = NO;
    translation.delegate = self;
    [self.viewWithContent.layer addAnimation:translation forKey:ECAnimationSwipeLeft];
}

- (IBAction)swipeRight:(id)sender
{
    self.viewWithContent.frame = CGRectMake(0, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
    [self.delegate cellDidSwipedIn:self];
}

#pragma mark - Animation

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.viewWithContent.layer animationForKey:ECAnimationSwipeLeft]) {
        self.viewWithContent.frame = CGRectMake(-self.buttonDeleteOutlet.frame.size.width, 0, self.viewWithContent.frame.size.width, self.viewWithContent.frame.size.height);
        [self.delegate cellDidSwipedOut:self];
        [self.viewWithContent.layer removeAnimationForKey:ECAnimationSwipeLeft];
    }
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
