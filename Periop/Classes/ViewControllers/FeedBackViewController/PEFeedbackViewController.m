//
//  PEFeedbackViewController.m
//  Periop
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEFeedbackViewController.h"
#import "PEMenuViewController.h"

@interface PEFeedbackViewController ()
@property (strong, nonatomic) UILabel * navigationBarLabel;

@end

@implementation PEFeedbackViewController

#pragma mark - LifeCycle

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
    [super viewDidLoad];
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    //add label to navigation Bar
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    //set text aligment - center
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    
    navigationLabel.text = @"Terms & Conditions";
    navigationLabel.textColor = [UIColor whiteColor];
    //background
    navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel = navigationLabel;
    
    //create button for menu
    UIBarButtonItem * menuBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuButton:)];
    //add button to navigation bar
    self.navigationItem.leftBarButtonItem=menuBarButton;
    //create button for menu
    UIBarButtonItem * sendButton = [[UIBarButtonItem alloc] initWithTitle:@"Send" style:UIBarButtonItemStyleBordered target:self action:@selector(sendButton:)];
    //add button to navigation bar
    self.navigationItem.rightBarButtonItem=sendButton;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBAction

- (IBAction)menuButton:(id)sender{
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
    menuController.navController = self.navigationController;
    menuController.textToShow= @"Feedback";
    [self presentViewController:menuController animated:YES completion:nil];
}

- (IBAction)sendButton:(id)sender{
    
}

@end
