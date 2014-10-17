//
//  IAPHelper.h
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@protocol IAPurchaseDelegate <NSObject>

@required
- (void)productWithIdentifier:(NSString *)productIdentifier purchasedWithSuccess:(BOOL)success error:(NSError *)error;

@end

@interface IAPHelper : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>

typedef void(^RequestProductCompletitionHandler)(BOOL success, NSArray *products);

@property (weak, nonatomic) id<IAPurchaseDelegate> delegate;

- (id)initWithProductsIdentifiers:(NSSet *)productsIdentifiers;
- (void)requestProductsWithCompletitonHelper:(RequestProductCompletitionHandler)completitionHandler;

- (void)buyProduct:(SKProduct *)product;
- (BOOL)isProductPurchased:(NSString *)productIdentifier;

- (void)restoreProductWithIdentifier:(NSString *)productIdentifier;

@end
