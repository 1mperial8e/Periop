//
//  PEMenuViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#define ANIMATION_DURATION 0.3f
#define ABOUT_US_NAME @"About Us"
#define SURGEON_LIST_NAME @"Surgeon List"
#define TERMS_COND_NAME @"Terms & Conditions"
#define FEEDBACK_NAME @"Feedback"

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
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonConstraint;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;

@end

@implementation PEMenuViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
   // self.navigationController.navigationBar.hidden = YES;
    self.menuTitleLabel.text=self.textToShow;
    if (self.isButtonVisible){
        self.viewWithButtons.hidden = NO;
        self.buttonConstraint.constant = 20.0f;
    }
    else{
        self.viewWithButtons.hidden = YES;
        self.buttonConstraint.constant = 0;
    }
    self.viewSelection.layer.cornerRadius = self.viewSelection.frame.size.height/2;
    self.viewSelection.hidden = YES;
   
}

- (void)viewDidLayoutSubviews
{
    CGPoint newCenter = self.view.center;
    newCenter.y -=self.view.frame.size.height;
    newCenter.y+=self.buttonPositionY + [UIApplication sharedApplication].statusBarFrame.size.height;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.duration = ANIMATION_DURATION;
    animation.fromValue = [NSValue valueWithCGPoint:newCenter];
    animation.toValue = [NSValue valueWithCGPoint:self.view.center];
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [self.view.layer addAnimation:animation forKey:@"showMenu"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)specialisationButton:(id)sender {
    self.menuTitleLabel.text = @"Specialisation";
    
    //set new center for point on menuView
    CGPoint newCenterForView = self.specializationButton.center;
    newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    PESpecialisationViewController * spesalisationView = [[PESpecialisationViewController alloc] initWithNibName:@"PESpecialisationViewController" bundle:nil];
    [self.navController pushViewController:spesalisationView animated:NO];
    [self createAnimationWithKey:@"hideMenuToSpecialisation"];
}

- (IBAction)suggestionListButton:(id)sender {
    self.menuTitleLabel.text = SURGEON_LIST_NAME;
    
    //set new center for point on menuView
    CGPoint newCenterForView = self.specializationButton.center;
    newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
    newCenterForView.y +=75;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    
    [self createAnimationWithKey:@"hideMenuToSurgeons"];
}

- (IBAction)aboutUsButton:(id)sender {
    self.menuTitleLabel.text = ABOUT_US_NAME;
    //set new center for point on menuView
    CGPoint newCenterForView = self.specializationButton.center;
    newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
    newCenterForView.y +=150;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    
    [self createAnimationWithKey:@"hideMenuToAbout"];
}

- (IBAction)termsAndConditionsButton:(id)sender {
    self.menuTitleLabel.text= TERMS_COND_NAME;
    
    //set new center for point on menuView
    CGPoint newCenterForView = self.specializationButton.center;
    newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
    newCenterForView.y +=225;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;

    [self createAnimationWithKey:@"hideMenuToTerms"];
}

- (IBAction)feedbackButton:(id)sender {
    self.menuTitleLabel.text= FEEDBACK_NAME;
    //set new center for point on menuView
    CGPoint newCenterForView = self.specializationButton.center;
    newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
    newCenterForView.y +=300;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;

    [self createAnimationWithKey:@"hideMenuToFeedback"];
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
    
    //create animation
    CABasicAnimation * animationToHide = [CABasicAnimation animationWithKeyPath:@"position"];
    animationToHide.duration = ANIMATION_DURATION;
    animationToHide.fromValue = [NSValue valueWithCGPoint:self.view.center];
    animationToHide.toValue = [NSValue valueWithCGPoint:toPoint];
    //do not complete
    animationToHide.removedOnCompletion = NO;
    //set delegate
    animationToHide.delegate = self;
    animationToHide.timingFunction =[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    //set key for animation
    [self.view.layer addAnimation:animationToHide forKey:key];
    //after animation finished remove layer
    self.view.layer.position= toPoint;
}

- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    if (anim==[self.view.layer animationForKey:@"hideMenuToMenu"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToMenu"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToSpecialisation"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToSpecialisation"];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToSurgeons"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToSurgeons"];
        PEDoctorsListViewController * doctorsView = [[PEDoctorsListViewController alloc] initWithNibName:@"PEDoctorsListViewController" bundle:nil];
        doctorsView.textToShow = SURGEON_LIST_NAME;
        doctorsView.isButtonRequired = true;
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navController pushViewController:doctorsView animated:NO];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToAbout"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToAbout"];
        PEAboutUsViewController * aboutView = [[PEAboutUsViewController alloc] initWithNibName:@"PEAboutUsViewController" bundle:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navController pushViewController:aboutView animated:NO];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToTerms"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToTerms"];
        PETermsAndConditionViewController * termsAndConditionView = [[PETermsAndConditionViewController alloc] initWithNibName:@"PETermsAndConditionViewController" bundle:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navController pushViewController:termsAndConditionView animated:NO];
    } else if (anim==[self.view.layer animationForKey:@"hideMenuToFeedback"]){
        [self.view.layer removeAnimationForKey:@"hideMenuToFeedback"];
        PEFeedbackViewController * feedbackView = [[PEFeedbackViewController alloc] initWithNibName:@"PEFeedbackViewController" bundle:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
        [self.navController pushViewController:feedbackView animated:NO];
    } else if (anim==[self.view.layer animationForKey:@"showMenu"]){
        [self.view.layer removeAnimationForKey:@"showMenu"];
        
        //set white view near name of opened viewcontroller
        if ([self.menuTitleLabel.text isEqualToString:SURGEON_LIST_NAME]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=75;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:ABOUT_US_NAME]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=150;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:TERMS_COND_NAME]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=225;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:FEEDBACK_NAME]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            newCenterForView.y +=300;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        } else if ([self.menuTitleLabel.text isEqualToString:@"Specialisations"]){
            CGPoint newCenterForView = self.specializationButton.center;
            newCenterForView.x = newCenterForView.x - self.specializationButton.frame.size.width/2-16;
            self.viewSelection.center = newCenterForView;
            self.viewSelection.hidden = NO;
        }
    }
}


@end
