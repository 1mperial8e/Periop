//
//  PEPurchaseManager.h
//  ScrubUp
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "IAPHelper.h"

@interface PEPurchaseManager : IAPHelper

+ (id)sharedManager;
+ (void)saveDefaultsToUserDefault:(NSString *)productIdentifier;

@end
