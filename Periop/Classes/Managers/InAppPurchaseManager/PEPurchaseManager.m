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
        NSSet * productsIdentifiers = [NSSet setWithObjects:
                                       @"com.Thinkmobiles.Periop.S01ENT",
                                       @"com.Thinkmobiles.Periop.S02Gyneacology",
                                       @"com.Thinkmobiles.Periop.S03Obstetric",
                                       @"com.Thinkmobiles.Periop.S04Opthalmology",
                                       @"com.Thinkmobiles.Periop.S05Cardiothoracic",
                                       @"com.Thinkmobiles.Periop.S06Orthopeadic",
                                       @"com.Thinkmobiles.Periop.S07Plastic",
                                       @"com.Thinkmobiles.Periop.S08Cosmetic",
                                       @"com.Thinkmobiles.Periop.S09General",
                                       @"com.Thinkmobiles.Periop.S10Gastrointestina", nil];
        
        sharedManager = [[PEPurchaseManager alloc] initWithProductsIdentifieer:productsIdentifiers];
    });
    return sharedManager;
}

+ (void) saveDefaultsToUserDefault: (NSString*)productIdentifier{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
