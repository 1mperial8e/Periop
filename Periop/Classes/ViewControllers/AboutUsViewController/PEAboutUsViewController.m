//
//  PEAboutUsViewController.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const AUVCTitleText = @"About Us";
static NSString *const AUVCNibName = @"PEMenuViewController";

#import "PEAboutUsViewController.h"
#import "PEMenuViewController.h"

@interface PEAboutUsViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PEAboutUsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = AUVCTitleText;
    
    self.textView.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:AUVCNibName bundle:nil];
    menuController.textToShow = AUVCTitleText;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
#ifdef __IPHONE_8_0
    menuController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

@end
