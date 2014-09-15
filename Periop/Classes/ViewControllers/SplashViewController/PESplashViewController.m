//
//  PELogoScreenViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESplashViewController.h"

@interface PESplashViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageLogo;
@property (weak, nonatomic) IBOutlet UILabel *downloadingLabel;

@end
#pragma mark - Lifecycle

@implementation PESplashViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.imageLogo.layer.cornerRadius = _imageLogo.frame.size.width/2;
        self.imageLogo.layer.borderColor = [UIColor grayColor].CGColor;
        self.imageLogo.layer.borderWidth = 1.0;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
