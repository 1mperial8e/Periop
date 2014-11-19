//
//  PEMailControllerConfigurator.m
//  ScrubUp
//
//  Created by Kirill on 11/19/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMailControllerConfigurator.h"
#import "UIImage+fixOrientation.h"

@implementation PEMailControllerConfigurator

+ (void)configureMailControllerBackgroundColor:(UIColor *)color
{
        [[UINavigationBar appearance] setBarTintColor:color];
        [[UINavigationBar appearance] setBackgroundImage:[UIImage imageWithColor:color] forBarMetrics:UIBarMetricsDefault];
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        [[UINavigationBar appearance] setTitleTextAttributes: [NSDictionary dictionaryWithObjectsAndKeys:
                                                               [UIColor whiteColor], NSForegroundColorAttributeName, nil]];
}

@end
