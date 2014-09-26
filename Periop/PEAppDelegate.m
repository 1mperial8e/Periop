//
//  PEAppDelegate.m
//  Periop
//
//  Created by Stas Volskyi on 04.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAppDelegate.h"
#import "PESpecialisationViewController.h"
#import "PEFeedbackViewController.h"
#import "PETermsAndConditionViewController.h"
#import "PEDoctorsListViewController.h"
#import "PEAboutUsViewController.h"
#import "PESpecialisationViewController.h"
#import "PECameraRollManager.h"

#import  "PEPurchaseManager.h"

@implementation PEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PEPurchaseManager sharedManager];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    PESpecialisationViewController * specializationController = [[PESpecialisationViewController alloc] initWithNibName:@"PESpecialisationViewController" bundle:nil];
    UINavigationController * specializationNavController = [self navControllerWithRootViewController:specializationController];
    
    PEFeedbackViewController *feedbackController = [[PEFeedbackViewController alloc] initWithNibName:@"PEFeedbackViewController" bundle:nil];
    UINavigationController * feedbackNavController = [self navControllerWithRootViewController:feedbackController];
    
    PETermsAndConditionViewController *termsController = [[PETermsAndConditionViewController alloc] initWithNibName:@"PETermsAndConditionViewController" bundle:nil];
    UINavigationController * termsNavController = [self navControllerWithRootViewController:termsController];
    
    PEDoctorsListViewController *doctorListController = [[PEDoctorsListViewController alloc] initWithNibName:@"PEDoctorsListViewController" bundle:nil];
    UINavigationController *doctorListNavController = [self navControllerWithRootViewController:doctorListController];
    
    PEAboutUsViewController *aboutUsController = [[PEAboutUsViewController alloc] initWithNibName:@"PEAboutUsViewController" bundle:nil];
    UINavigationController *aboutUsNavController = [self navControllerWithRootViewController:aboutUsController];

    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[specializationNavController, doctorListNavController, aboutUsNavController, termsNavController, feedbackNavController];
    tabController.tabBar.hidden = YES;

    self.window.rootViewController = tabController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[PECameraRollManager sharedInstance] getPhotosFromCameraRoll];
    
    return YES;
}

#pragma mark - Private

- (UINavigationController *)navControllerWithRootViewController:(UIViewController *)vievController
{
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:vievController];
    navController.navigationBar.translucent = NO;
    navController.navigationBar.barTintColor = [UIColor colorWithRed:75/255.0 green:157/255.0 blue:225/255.0 alpha:1];
    navController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImage *buttonImage = [UIImage imageNamed:@"Menu"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem * menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:vievController action:NSSelectorFromString(@"menuButton:") forControlEvents:UIControlEventTouchUpInside];
    
    vievController.navigationItem.leftBarButtonItem = menuBarButton;
    return navController;
}

#pragma mark - Rotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *currentViewController = [self topViewController];
    if ([currentViewController respondsToSelector:NSSelectorFromString(@"canRotate")]) {
        return UIInterfaceOrientationMaskAllButUpsideDown;
        [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (UIViewController*)topViewController
{
    return [self topViewControllerWithRootViewController:[UIApplication sharedApplication].keyWindow.rootViewController];
}

- (UIViewController*)topViewControllerWithRootViewController:(UIViewController*)rootViewController
{
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
