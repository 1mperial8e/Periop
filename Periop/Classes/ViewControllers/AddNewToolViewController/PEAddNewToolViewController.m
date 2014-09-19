//
//  PEAddNewToolViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddNewToolViewController.h"

@interface PEAddNewToolViewController ()

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextField *nameTextBox;
@property (weak, nonatomic) IBOutlet UITextField *specTextBox;
@property (weak, nonatomic) IBOutlet UITextField *qtyTextBox;

@end

@implementation PEAddNewToolViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.text =@"Procedure Name";
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    [self.navigationItem setHidesBackButton:YES];
    
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"X" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelButton:)];
    self.navigationItem.leftBarButtonItem = cancelButton;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)saveButton:(id)sender{
    
}
- (IBAction)cancelButton:(id)sender{
    [self.navigationController popViewControllerAnimated:NO];
}

@end
