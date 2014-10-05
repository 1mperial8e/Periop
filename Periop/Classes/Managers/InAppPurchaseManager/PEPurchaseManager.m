//
//  PEPurchaseManager.m
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const CPPlistSpecialisationPicsAndCode = @"SpecialisationPicsAndCode";
static NSString *const CPPlistProductIdentifierKey = @"productIdentifier";

#import "PEPurchaseManager.h"

@implementation PEPurchaseManager

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CPPlistSpecialisationPicsAndCode ofType:@"plist" ]];
        NSMutableSet *setWithProductIdentifiers = [NSMutableSet new];
        for (int i = 0; i < [pList allKeys].count; i++) {
            NSDictionary *dict = [pList valueForKey:[pList allKeys][i]];
            [setWithProductIdentifiers addObject:[dict valueForKey:CPPlistProductIdentifierKey]];
        }
        sharedManager = [[PEPurchaseManager alloc] initWithProductsIdentifieer:setWithProductIdentifiers];
    });
    return sharedManager;
}

+ (void)saveDefaultsToUserDefault:(NSString *)productIdentifier
{
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
