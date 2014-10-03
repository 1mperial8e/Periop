//
//  PEMenuViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "PEMenuViewController.h"
#import "PEDoctorsListViewController.h"
#import "PESpecialisationViewController.h"
#import "PEAboutUsViewController.h"
#import "PETermsAndConditionViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIImage+ImageWithJPGFile.h"

static CGFloat const MVCAnimationDuration = 0.5f;
static NSString *const MVCTermsAndConditions = @"Terms & Conditions";
static NSString *const MVCAboutUs = @"About Us";
static NSString *const MVCSurgeonList = @"Surgeon List";
static NSString *const MVCTermsAndCond = @"Terms & Conditions";
static NSString *const MVCFeedback = @"Feedback";
static NSString *const MVCSpecialisation = @"Specialisations";

@interface PEMenuViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *viewWithButtons;
@property (weak, nonatomic) IBOutlet UIButton *menuButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomButtonsViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *mySpecialisationsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreSpecialisationsButton;

@property (weak, nonatomic) IBOutlet UIButton *specialisationButton;
@property (weak, nonatomic) IBOutlet UIButton *surgeonListButton;
@property (weak, nonatomic) IBOutlet UIButton *aboutUsButton;
@property (weak, nonatomic) IBOutlet UIButton *termsButton;
@property (weak, nonatomic) IBOutlet UIButton *feedbackButton;

@property (weak, nonatomic) UITabBarController *tabBarController;
@property (assign, nonatomic) BOOL isFeedbackPresented;

@end

@implementation PEMenuViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.menuTitleLabel.text = self.textToShow;
    self.menuTitleLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0];
    
    [self setupButtons];
    self.viewSelection.layer.cornerRadius = self.viewSelection.frame.size.height/2;   
    self.tabBarController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    
    self.isFeedbackPresented = NO;
}

- (void)viewDidLayoutSubviews{
    
    [super viewDidLayoutSubviews];
    
    if (!self.isFeedbackPresented) {
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
        self.isFeedbackPresented = YES;
    }
}

#pragma mark - IBActions

- (IBAction)specialisationButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    self.menuTitleLabel.text = MVCSpecialisation;
    [self createAnimationWithKey:@"hideMenuToSpecialisation"];
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[0];
}

- (IBAction)suggestionListButton:(id)sender
{
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    self.menuTitleLabel.text = MVCSurgeonList;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[1];
    [self createAnimationWithKey:@"hideMenuToSurgeons"];
    [self hideBottomButtons];
}

- (IBAction)aboutUsButton:(id)sender
{
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    self.menuTitleLabel.text = MVCAboutUs;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[2];
    [self createAnimationWithKey:@"hideMenuToAbout"];
    [self hideBottomButtons];
}
    
- (IBAction)termsAndConditionsButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    self.menuTitleLabel.text= MVCTermsAndConditions;
    self.tabBarController.selectedViewController = self.tabBarController.viewControllers[3];
    [self createAnimationWithKey:@"hideMenuToTerms"];
    [self hideBottomButtons];
}

- (IBAction)feedbackButton:(id)sender {
    CGPoint newCenterForView = ((UIButton *)sender).center;
    newCenterForView.x = ((UIButton *)sender).frame.origin.x / 2;
    self.viewSelection.center = newCenterForView;
    self.viewSelection.hidden = NO;
    self.menuTitleLabel.text = MVCFeedback;
    
    if ([MFMailComposeViewController canSendMail]) {
        [UINavigationBar appearance].barTintColor = [UIColor colorWithRed:75/255.0 green:157/255.0 blue:225/255.0 alpha:1];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor], NSForegroundColorAttributeName,  nil]];
        
        MFMailComposeViewController * mailController = [[MFMailComposeViewController alloc] init];
        mailController.mailComposeDelegate = self;
        [mailController setSubject:@"Feedback"];
        NSString * message = @"Feedback :";
        [mailController setMessageBody:message isHTML:NO];
        PEMenuViewController *menuController = self;
        [menuController presentViewController:mailController animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            menuController.viewSelection.hidden = YES;
        }];
        self.isFeedbackPresented = YES;
        menuController.viewSelection.hidden = NO;
        
    } else {
        UIAlertView * alerMail = [[UIAlertView alloc] initWithTitle:@"E-mail settings" message:@"Please configure your e-mails setting before sending message" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alerMail show];
    }
}

- (IBAction)menuButton:(id)sender
{
    [self createAnimationWithKey:@"hideMenuToMenu"];
}

- (IBAction)mySpecialisationButton:(id)sender
{
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Active"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Inactive"] forState:UIControlStateNormal];
    [self createAnimationWithKey:@"hideMenuToMenuMySpecialisation"];
}

- (IBAction)moreSpecialisationButton:(id)sender
{
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Inactive"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Active"] forState:UIControlStateNormal];
    [self createAnimationWithKey:@"hideMenuToMenuMoreSpecialisation"];
}

#pragma mark - Animation

- (void)createAnimationWithKey:(NSString*)key
{
    CGPoint  toPoint = self.view.center;
    toPoint.y -= self.view.frame.size.height-self.buttonPositionY - [UIApplication sharedApplication].statusBarFrame.size.height;
    
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

- (void)hideBottomButtons
{
    if (self.bottomButtonsViewHeight.constant > 0) {
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.removedOnCompletion = YES;
        opacity.duration = MVCAnimationDuration / 2;
        opacity.fromValue = @1;
        opacity.toValue = @0;
        [self.viewWithButtons.layer addAnimation:opacity forKey:nil];
        self.viewWithButtons.layer.opacity = 0;
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.view.layer animationForKey:@"hideMenuToMenu"]) {
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
    } else if (anim == [self.view.layer animationForKey:@"hideMenuToMenuMoreSpecialisation"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"moreSpecButton" object:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim == [self.view.layer animationForKey:@"hideMenuToMenuMySpecialisation"]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"mySpecButton" object:nil];
        [self dismissViewControllerAnimated:NO completion:nil];
    } else if (anim==[self.view.layer animationForKey:@"showMenu"]){
        [self.view.layer removeAnimationForKey:@"showMenu"];
        
        CGPoint center;
        if ([self.menuTitleLabel.text isEqualToString:MVCSurgeonList]){
            center = self.surgeonListButton.center;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCAboutUs]){
            center = self.aboutUsButton.center;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCTermsAndConditions]){
            center = self.termsButton.center;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCFeedback]){
            center = self.feedbackButton.center;
        } else if ([self.menuTitleLabel.text isEqualToString:MVCSpecialisation]){
            center = self.specialisationButton.center;
        }
        center.x = self.specialisationButton.frame.origin.x / 2;
        self.viewSelection.center = center;
        self.viewSelection.hidden = NO;
    }
}

#pragma mark - MailComposerDelegate

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result) {
        switch (result) {
            case MFMailComposeResultSent:
                NSLog(@"You sent the email.");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"You saved a draft of this email");
                break;
            case MFMailComposeResultCancelled:
                NSLog(@"You cancelled sending this email.");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"Mail failed:  An error occurred when trying to compose this email");
                break;
            default:
                NSLog(@"An error occurred when trying to compose this email");
                break;
        }
    }
    if (error) {
        NSLog(@"Error to send mail - %@", error.localizedDescription);
    }
    PEMenuViewController *menuController = self;
    [menuController dismissViewControllerAnimated:YES completion:^ {
        CGPoint center;
        center = menuController.feedbackButton.center;
        center.x = menuController.feedbackButton.frame.origin.x / 2;
        menuController.viewSelection.center = center;
        menuController.viewSelection.hidden = NO;
    }];
    
}

#pragma mark - Private

- (void)setupButtons
{
    if ([self.textToShow isEqualToString:@"Specialisations"]) {
        self.viewWithButtons.hidden = NO;
        self.bottomButtonsViewHeight.constant = 30.0f;
        if (self.isButtonMySpecializations) {
            [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Active"] forState:UIControlStateNormal];
            [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Inactive"] forState:UIControlStateNormal];
        } else {
            [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Inactive"] forState:UIControlStateNormal];
            [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Active"] forState:UIControlStateNormal];
        }
    }
    else{
        self.viewWithButtons.hidden = YES;
        self.bottomButtonsViewHeight.constant = 0.0f;
    }
    
    UIFont *menuButtonFont = [UIFont fontWithName:FONT_MuseoSans100 size:22.5];
    
    self.specialisationButton.titleLabel.font = menuButtonFont;
    self.surgeonListButton.titleLabel.font = menuButtonFont;
    self.aboutUsButton.titleLabel.font = menuButtonFont;
    self.feedbackButton.titleLabel.font = menuButtonFont;
    self.termsButton.titleLabel.font = menuButtonFont;
}

@end
