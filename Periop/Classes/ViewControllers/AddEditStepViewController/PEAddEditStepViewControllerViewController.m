//
//  PEAddEditStepViewControllerViewController.m
//  Periop
//
//  Created by Stas Volskyi on 16.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAddEditStepViewControllerViewController.h"
#import "UIImage+ImageWithJPGFile.h"

@interface PEAddEditStepViewControllerViewController ()

@property (weak, nonatomic) IBOutlet UILabel *stepLabel;
@property (weak, nonatomic) IBOutlet UILabel *borderLabel;
@property (weak, nonatomic) IBOutlet UITextView *stepTextView;

@end

@implementation PEAddEditStepViewControllerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupUI];
}

- (void)setupUI
{
    self.stepLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:20.0f];
    self.stepTextView.font = [UIFont fontWithName:FONT_MuseoSans500 size:11.5f];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveUpdateStep:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans500 size:13.5f]} forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.borderLabel.layer.cornerRadius = 24;
    self.borderLabel.layer.borderColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    self.borderLabel.layer.borderWidth = 1;
    
    self.stepLabel.text = self.stepNumber;
    self.stepTextView.text = self.stepText;    
    [self.stepTextView becomeFirstResponder];
}

#pragma mark - Actions

- (void)closeButton:(UIBarButtonItem *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)saveUpdateStep:(UIBarButtonItem *)sender
{
    // save result!
    [self.navigationController popViewControllerAnimated:YES];
}

@end
