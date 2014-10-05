//
//  PEDoctorsViewTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//
static NSString *const DVTVCAnimationSwipeLeft = @"swipeLeft";
static NSString *const DVTVCAnimationKeyPath = @"transform.translation.x";
static CGFloat const DVTVAnimationDuration = 0.2f;
static CGFloat const DVTVMultiplier = 1.8f;

#import "PEDoctorsViewTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

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
    CAKeyframeAnimation *translation = [CAKeyframeAnimation animationWithKeyPath:DVTVCAnimationKeyPath];
    translation.duration = DVTVAnimationDuration;
    NSMutableArray *values = [[NSMutableArray alloc] init];
    [values addObject:[NSNumber numberWithFloat:0.0f]];
    [values addObject:[NSNumber numberWithFloat:-self.deleteButton.frame.size.width * DVTVMultiplier]];
    translation.values = values;
    NSMutableArray *timingFunction = [[NSMutableArray alloc] init];
    [timingFunction addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
    translation.timingFunctions = timingFunction;
    translation.removedOnCompletion = NO;
    translation.delegate = self;
    [self.viewDoctorsNameView.layer addAnimation:translation forKey:DVTVCAnimationSwipeLeft];
    
}

- (IBAction)swipeRight:(id)sender
{
   self.viewDoctorsNameView.frame = CGRectMake(0, 0, self.viewDoctorsNameView.frame.size.width, self.viewDoctorsNameView.frame.size.height);
    [self.delegate cellDidSwipedIn:self];
}

#pragma mark - Animation

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.viewDoctorsNameView.layer animationForKey:DVTVCAnimationSwipeLeft]) {
        self.viewDoctorsNameView.frame = CGRectMake(-self.deleteButton.frame.size.width, 0, self.viewDoctorsNameView.frame.size.width, self.viewDoctorsNameView.frame.size.height);
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
