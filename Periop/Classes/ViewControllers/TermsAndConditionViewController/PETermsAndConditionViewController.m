//
//  PETermsAndConditionViewController.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PETermsAndConditionViewController.h"
#import "PEMenuViewController.h"

@interface PETermsAndConditionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) UILabel * navigationBarLabel;

@end

@implementation PETermsAndConditionViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.text = @"Terms & Conditions";
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender{
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.sizeOfFontInNavLabel = self.navigationBarLabel.font.pointSize;
    menuController.textToShow = @"Terms & Conditions";
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

@end
