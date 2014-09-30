//
//  PEPurchaseManager.m
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPurchaseManager.h"

@implementation PEPurchaseManager

+ (id)sharedManager{
    static id sharedManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSSet * productsIdentifiers = [NSSet setWithObjects:@"generalProductsIdentifier", @"identifier1", @"identifier2", nil];
        sharedManager = [[PEPurchaseManager alloc] initWithProductsIdentifieer:productsIdentifiers];
    });
    return sharedManager;
}

+ (void) saveDefaultsToUserDefault: (NSString*)productIdentifier{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
