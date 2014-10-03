//
//  IAPHelper.m
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "IAPHelper.h"
#import <StoreKit/StoreKit.h>

NSString *const  IAPHelperProductPurchasedNotification = @"IAHelperProductPurchaseNotification";

@interface IAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) SKProductsRequest *productRequest;
@property (strong, nonatomic) RequestProductCompletitionHandler completitionHadler;

@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;

@end

@implementation IAPHelper

#pragma mark - Singleton

- (id)initWithProductsIdentifieer:(NSSet *)productsIdentifier
{
    if (self = [super init]) {
        self.productIdentifiers = productsIdentifier;

        self.purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString *prodIdentifier in self.productIdentifiers) {
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:prodIdentifier];
            if (productPurchased){
                [self.purchasedProductIdentifiers addObject:prodIdentifier];
                NSLog(@"Prev purchased: %@", prodIdentifier);
            } else {
                NSLog(@"Not purchased %@", prodIdentifier);
            }
        }
    }
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    return self;
}

- (void)requestProductsWithCompletitonHelper:(RequestProductCompletitionHandler)completitionHandler
{
    self.completitionHadler = [completitionHandler copy];
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
    self.productRequest.delegate = self;
    [self.productRequest start];
}

#pragma mark - SKProductsRequestDelegate 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    NSLog(@"Loading list of products...");
    self.productRequest = nil;
    
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts){
        NSLog(@"Found products %@ %@ %@", skProduct.productIdentifier, skProduct.localizedTitle, [self getFormattedLocalePrice:skProduct]);
    }
    self.completitionHadler (YES, skProducts);
    self.completitionHadler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed to load list with products %@", error.localizedDescription);
    self.productRequest = nil;
    self.completitionHadler (NO, nil);
    self.completitionHadler = nil;
}

#pragma mark - SKPaymentTransactionObserver protocol

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchased:{
                [self completeTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateFailed:{
                [self failedTransaction:transaction];
                break;
            }
            case SKPaymentTransactionStateRestored:{
                [self restoreTransaction:transaction];
                break;
            }
            default:
                break;
        }
    }
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"complete transaction");
    [self provideContentForProductIdentifier: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"restore transaction");
    [self provideContentForProductIdentifier: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
    NSLog(@"failed transaction");
    if (transaction.error.code !=SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [self.purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}

#pragma mark - PriceFormatter 

- (NSString *)getFormattedLocalePrice:(SKProduct *)product
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString *formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

#pragma mark - Purchasing

- (BOOL)productPurchased:(NSString *)productIdentifier
{
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@", product.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Restoring Old Purchases for Current Account

- (void)restoreCompleteTransactions
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
