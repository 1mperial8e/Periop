//
//  PEAppDelegate.m
//  ScrubUp
//
//  Created by Stas Volskyi on 04.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEAppDelegate.h"
#import "PESpecialisationViewController.h"
#import "PETermsAndConditionViewController.h"
#import "PEDoctorsListViewController.h"
#import "PEAboutUsViewController.h"
#import "PECameraRollManager.h"
#import "PEPurchaseManager.h"
#import "PEGAManager.h"

static NSString *const PESpecialisationControllerNibName = @"PESpecialisationViewController";
static NSString *const PETermsAndConditionControllerNibName = @"PETermsAndConditionViewController";
static NSString *const PEDoctorsListControllerNibName = @"PEDoctorsListViewController";
static NSString *const PEAboutUsControllerNibName = @"PEAboutUsViewController";
static NSString *const APDGeneralProductsIdentifier = @"com.Thinkmobiles.Periop.S09General";

@interface PEAppDelegate() 

@property (strong, nonatomic) UITabBarController *tabBarController;

@end

@implementation PEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [PEPurchaseManager saveDefaultsToUserDefault:APDGeneralProductsIdentifier];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    PESpecialisationViewController *specializationController = [[PESpecialisationViewController alloc] initWithNibName:PESpecialisationControllerNibName bundle:nil];
    PENavigationController *specializationNavController = [[PENavigationController alloc] initWithRootViewController:specializationController];
    
    PETermsAndConditionViewController *termsController = [[PETermsAndConditionViewController alloc] initWithNibName:PETermsAndConditionControllerNibName bundle:nil];
    PENavigationController *termsNavController = [[PENavigationController alloc] initWithRootViewController:termsController];
    
    PEDoctorsListViewController *doctorListController = [[PEDoctorsListViewController alloc] initWithNibName:PEDoctorsListControllerNibName bundle:nil];
    PENavigationController *doctorListNavController = [[PENavigationController alloc] initWithRootViewController:doctorListController];
    
    PEAboutUsViewController *aboutUsController = [[PEAboutUsViewController alloc] initWithNibName:PEAboutUsControllerNibName bundle:nil];
    PENavigationController *aboutUsNavController = [[PENavigationController alloc] initWithRootViewController:aboutUsController];

    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[specializationNavController, doctorListNavController, aboutUsNavController, termsNavController];
    tabController.tabBar.hidden = YES;

    self.window.rootViewController = tabController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    [[PECameraRollManager sharedInstance] getPhotosFromCameraRoll];
    [PEGAManager sharedManager];
    
    return YES;
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[PECameraRollManager sharedInstance] getPhotosFromCameraRoll];
}

#pragma mark - Rotation

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    UIViewController *currentViewController = [self topViewController];
    if ([currentViewController respondsToSelector:NSSelectorFromString(@"canRotate")]) {
        return UIInterfaceOrientationMaskAll;
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
        UITabBarController *tabBarController = (UITabBarController*)rootViewController;
        return [self topViewControllerWithRootViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*)rootViewController;
        return [self topViewControllerWithRootViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController *presentedViewController = rootViewController.presentedViewController;
        return [self topViewControllerWithRootViewController:presentedViewController];
    } else {
        return rootViewController;
    }
}

@end
