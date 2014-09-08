//
//  PEMenuViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMenuViewController.h"
#import "PEDoctorsListViewController.h"
#import "PESpecializationViewController.h"
#import "PEAboutUsViewController.h"
#import "PETermsAndConditionViewController.h"
#import "PEFeedbackViewController.h"

@interface PEMenuViewController ()

@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)specialisationButton:(id)sender {
    PESpecializationViewController * spesalisationView = [[PESpecializationViewController alloc] initWithNibName:@"PESpecializationViewController" bundle:nil];
    spesalisationView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navController pushViewController:spesalisationView animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)suggestionListButton:(id)sender {    
    PEDoctorsListViewController * doctorsView = [[PEDoctorsListViewController alloc] initWithNibName:@"PEDoctorsListViewController" bundle:nil];
    doctorsView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    doctorsView.textToShow = @"Doctors";
    doctorsView.isButtonRequired = true;
    [self.navController pushViewController:doctorsView animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)aboutUsButton:(id)sender {
    PEAboutUsViewController * aboutView = [[PEAboutUsViewController alloc] initWithNibName:@"PEAboutUsViewController" bundle:nil];
    aboutView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navController pushViewController:aboutView animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)termsAndConditionsButton:(id)sender {
    PETermsAndConditionViewController * termsAndConditionView = [[PETermsAndConditionViewController alloc] initWithNibName:@"PETermsAndConditionViewController" bundle:nil];
    termsAndConditionView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navController pushViewController:termsAndConditionView animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)feedbackButton:(id)sender {
    PEFeedbackViewController * feedbackView = [[PEFeedbackViewController alloc] initWithNibName:@"PEFeedbackViewController" bundle:nil];
    feedbackView.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navController pushViewController:feedbackView animated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)menuButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)mySpesializationButton:(id)sender {

}

- (IBAction)moreSpecialisationButton:(id)sender {
    
}
@end
