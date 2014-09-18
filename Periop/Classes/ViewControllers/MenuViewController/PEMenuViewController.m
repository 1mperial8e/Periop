//
//  PEMenuViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static CGFloat const MVCAnimationDuration = 0.3f;
static NSString *const MVCTermsAndConditions = @"Terms & Conditions";
static NSString* const MVCAboutUs = @"About Us";
static NSString* const MVCSurgeonList = @"Surgeon List";
static NSString* const MVCTermsAndCond = @"Terms & Conditions";
static NSString* const MVCFeedback = @"Feedback";
static NSString* const MVCSpecialisation = @"Specialisations";

#import <QuartzCore/QuartzCore.h>
#import "PEMenuViewController.h"
#import "PEDoctorsListViewController.h"
#import "PESpecialisationViewController.h"
#import "PEAboutUsViewController.h"
#import "PETermsAndConditionViewController.h"
#import "PEFeedbackViewController.h"

@interface PEMenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (assign, nonatomic) CGPoint centerOfScreen;
@property (assign, nonatomic) CGPoint sizeOfScreen;
@property (weak, nonatomic) IBOutlet UIView *viewWithButtons;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@property (weak, nonatomic) UITabBarController *tabBarController;

@end

@implementation PEMenuViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuTitleLabel.text=self.textToShow;
    
    if (self.isButtonVisible){
        self.viewWithButtons.hidden = NO;
    }
    else{
        self.viewWithButtons.hidden = YES;
    }
    
    self.viewSelection.layer.cornerRadius = self.viewSelection.frame.size.height/2;   
    self.tabBarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
}

- (void)viewDidLayoutSubviews{
    CGPoint newCenter = self.view.center;
    newCenter.y -= self.view.frame.size.height;
    newCenter.y+= self.buttonPositionY + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = MVCAnimationDuration;
    animation.fromValue = [NSValue valueWithCGPoint:newCenter];
    animation.toValue = [NSValue valueWithCGPoint:self.view.center];
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:animation forKey:@"showMenu"];
}

#pragma mark - IBActions

- (IBAction)specialisationButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    if ([self.menuTitleLabel.text isEqualToString:MVCSpecialisation] && [((UIButton *)sender).titleLabel.text isEqualToString:MVCSpecialisation]){
        [self createAnimationWithKey:@"hideMenuToSpecialisation"];
    } else {
        self.menuTitleLabel.text = MVCSpecialisation;
        [self createAnimationWithKey:@"hideMenuToSpecialisation"];
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
    }
}

- (IBAction)suggestionListButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    if ([self.menuTitleLabel.text isEqualToString:MVCSurgeonList] && [((UIButton *)sender).titleLabel.text isEqualToString:MVCSurgeonList]){
        [self createAnimationWithKey:@"hideMenuToSurgeons"];
    } else {
        self.menuTitleLabel.text = MVCSurgeonList;
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[1];
        [self createAnimationWithKey:@"hideMenuToSurgeons"];
    }
}

- (IBAction)aboutUsButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    if ([self.menuTitleLabel.text isEqualToString:MVCAboutUs] && [((UIButton *)sender).titleLabel.text isEqualToString:MVCAboutUs]){
        [self createAnimationWithKey:@"hideMenuToAbout"];
    } else {
        self.menuTitleLabel.text = MVCAboutUs;
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[2];
        [self createAnimationWithKey:@"hideMenuToAbout"];
    }
}

- (IBAction)termsAndConditionsButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    if ([self.menuTitleLabel.text isEqualToString:MVCTermsAndConditions] && [((UIButton *)sender).titleLabel.text isEqualToString:MVCTermsAndConditions]){
        [self createAnimationWithKey:@"hideMenuToTerms"];
    } else {
        self.menuTitleLabel.text= MVCTermsAndConditions;
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[3];
        [self createAnimationWithKey:@"hideMenuToTerms"];
    }
}

- (IBAction)feedbackButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    if ([self.menuTitleLabel.text isEqualToString:MVCFeedback] && [((UIButton *)sender).titleLabel.text isEqualToString:MVCFeedback]){
        [self createAnimationWithKey:@"hideMenuToFeedback"];
    } else {
        self.menuTitleLabel.text = MVCFeedback;
        self.tabBarController.selectedViewController = self.tabBarController.viewControllers[4];
        [self createAnimationWithKey:@"hideMenuToFeedback"];
    }
}

- (IBAction)menuButton:(id)sender {
    [self createAnimationWithKey:@"hideMenuToMenu"];
}

- (IBAction)mySpesializationButton:(id)sender {
    
}

- (IBAction)moreSpecialisationButton:(id)sender {
    
}

#pragma mark - Animation

- (void)createAnimationWithKey: (NSString*) key{
    self.navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    CGPoint  toPoint = self.view.center;
    toPoint.y -=self.view.frame.size.height-self.buttonPositionY - [UIApplication sharedApplication].statusBarFrame.size.height;

    CABasicAnimation * animationToHide = [CABasicAnimation animationWithKeyPath:@"position"];
    animationToHide.duration = MVCAnimationDuration;
    animationToHide.fromValue = [NSValue valueWithCGPoint:self.view.center];
    animationToHide.toValue = [NSValue valueWithCGPoint:toPoint];
    animationToHide.removedOnCompletion = NO;
    animationToHide.delegate = self;
    animationToHide.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:animationToHide forKey:key];
    self.view.layer.position= toPoint;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim==[self.view.layer animationForKey:@"hideMenuToMenu"]) {
        [self.view.layer removeAnimationForKey:@"hideMenuToMenu"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToSpecialisation"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToSpecialisation"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToSurgeons"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToSurgeons"];
         [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToAbout"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToAbout"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToTerms"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToTerms"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToFeedback"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToFeedback"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"showMenu"]){
        [self.view.layer removeAnimationForKey:@"showMenu"];
        
        if ([self.menuTitleLabel.text isEqualToString:MVCSurgeonList]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=75;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCAboutUs]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=150;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCTermsAndConditions]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=225;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCFeedback]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=300;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCSpecialisation]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        }
    }
}


@end
