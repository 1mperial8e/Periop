//
//  IAPHelper.h
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//
#import <StoreKit/StoreKit.h>
#import <Foundation/Foundation.h>

UIKIT_EXTERN NSString * const IAPHelperProductPurchasedNotification;

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

typedef void (^RequestProductCompletitionHandler)(BOOL success, NSArray* products);

- (id) initWithProductsIdentifieer : (NSSet *) productsIdentifier;
- (void)requestProductsWithCompletitonHelper: (RequestProductCompletitionHandler)completitionHandler;

//buying product
- (void)buyProduct: (SKProduct*)product;
- (BOOL)productPurchased:(NSString*) productIdentifier;

//restoring already purchased products
- (void)restoreCompleteTransactions;

@end
