//
//  PEDownloadingScreenViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDownloadingScreenViewController.h"
#import "PEPurchaseManager.h"

@interface PEDownloadingScreenViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation PEDownloadingScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self showView];
}

#pragma mark - Private

- (void)showView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.33;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.removedOnCompletion = YES;
    [self.view.layer addAnimation:animation forKey:nil];
    [self.activityIndicator startAnimating];
}

- (void)hideView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.33;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.view.layer addAnimation:animation forKey:@"hide"];
    self.view.layer.opacity = 0;
}

- (void)setupUI
{
    self.logoImage.image = [UIImage imageNamed:[self.specialisationInfo valueForKey:@"logo"]];
    self.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:17.5f];
}

#pragma mark - Animations delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.view.layer animationForKey:@"hide"]) {
        [self.view.layer removeAnimationForKey:@"hide"];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

@end
