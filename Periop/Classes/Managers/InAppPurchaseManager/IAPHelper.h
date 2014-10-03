//
//  IAPHelper.h
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//
#import <StoreKit/StoreKit.h>

extern NSString *const IAPHelperProductPurchasedNotification;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

typedef void(^RequestProductCompletitionHandler)(BOOL success, NSArray *products);

- (id)initWithProductsIdentifieer:(NSSet *)productsIdentifier;
- (void)requestProductsWithCompletitonHelper:(RequestProductCompletitionHandler)completitionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)productPurchased:(NSString *)productIdentifier;

- (void)restoreCompleteTransactions;

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier;

@end
