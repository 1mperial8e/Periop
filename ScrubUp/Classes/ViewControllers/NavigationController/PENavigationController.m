//
//  PENavigationController.m
//  ScrubUp
//
//  Created by Admin on 01.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PENavigationController.h"
#import "UIImage+ImageWithJPGFile.h"

@implementation PENavigationController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.navigationBar.translucent = NO;
        self.navigationBar.barTintColor = UIColorFromRGB(0x4B9DE1);
        self.navigationBar.tintColor = [UIColor whiteColor];
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {        
        UIImage *buttonImage = [UIImage imageNamedFile:@"Menu"];
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
        [button setImage:buttonImage forState:UIControlStateNormal];
        UIBarButtonItem *menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
        [button addTarget:rootViewController action:NSSelectorFromString(@"menuButton:") forControlEvents:UIControlEventTouchUpInside];
        
        rootViewController.navigationItem.leftBarButtonItem = menuBarButton;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGSize navBarSize = self.navigationBar.frame.size;
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height *2,  navBarSize.height)];
    self.titleLabel.minimumScaleFactor = 0.5;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.center = CGPointMake(navBarSize.width / 2, navBarSize.height / 2);
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20.0];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.numberOfLines = 0;
    
    [self.navigationBar addSubview:self.titleLabel];
}

@end
