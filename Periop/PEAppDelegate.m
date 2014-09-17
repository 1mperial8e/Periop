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
#import "PEProcedureListViewController.h"
#import "PESpecialisationViewController.h"

@implementation PEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
    
    PEProcedureListViewController *procedureListController = [[PEProcedureListViewController alloc] initWithNibName:@"PEProcedureListViewController" bundle:nil];
    UINavigationController *procedureListNavController = [self navControllerWithRootViewController:procedureListController];
    
    UITabBarController *tabController = [[UITabBarController alloc] init];
    tabController.viewControllers = @[specializationNavController, doctorListNavController, aboutUsNavController, termsNavController, feedbackNavController, procedureListNavController];
    tabController.tabBar.hidden = YES;

    tabController.moreNavigationController.navigationBar.translucent = NO;
    tabController.moreNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:75/255.0 green:157/255.0 blue:225/255.0 alpha:1];
    tabController.moreNavigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    UIImage *buttonImage = [UIImage imageNamed:@"Menu"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, buttonImage.size.width, buttonImage.size.height)];
    [button setImage:buttonImage forState:UIControlStateNormal];
    UIBarButtonItem * menuBarButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    [button addTarget:tabController.moreNavigationController.topViewController action:NSSelectorFromString(@"menuButton:") forControlEvents:UIControlEventTouchUpInside];
    
    tabController.moreNavigationController.navigationItem.leftBarButtonItem = menuBarButton;
    
    tabController.moreNavigationController.navigationBar.translucent = NO;
    tabController.moreNavigationController.navigationBar.barTintColor = [UIColor colorWithRed:75/255.0 green:157/255.0 blue:225/255.0 alpha:1];
    tabController.moreNavigationController.navigationBar.tintColor = [UIColor whiteColor];

    self.window.rootViewController = tabController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

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


@end
