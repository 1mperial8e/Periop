//
//  IAPHelper.m
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "IAPHelper.h"

@interface IAPHelper()

@property (strong, nonatomic) SKProductsRequest *productRequest;
@property (strong, nonatomic) RequestProductCompletitionHandler completitionHadler;
@property (strong, nonatomic) NSSet *productIdentifiers;
@property (strong, nonatomic) NSMutableSet *purchasedProductIdentifiers;
@property (strong, nonatomic) NSString *productIdentifierToRestore;

@end

@implementation IAPHelper

#pragma mark - Singleton

- (id)initWithProductsIdentifiers:(NSSet *)productsIdentifiers;
{
    if (self = [super init]) {
        self.productIdentifiers = productsIdentifiers;

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
    NSArray *skProducts = response.products;
    for (SKProduct *skProduct in skProducts){
        NSLog(@"Found products %@ %@ %@", skProduct.productIdentifier, skProduct.localizedTitle, [self getFormattedLocalePrice:skProduct]);
    }
    self.completitionHadler (YES, skProducts);
//    self.completitionHadler = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    NSLog(@"Failed to load list with products %@", error.localizedDescription);
    self.completitionHadler (NO, nil);
//    self.completitionHadler = nil;
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    
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
    [self provideContentForProductIdentifier: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(productWithIdentifier:purchasedWithSuccess:error:)]) {
        [self.delegate productWithIdentifier:transaction.payment.productIdentifier purchasedWithSuccess:YES error:nil];
    }
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction
{
    [self provideContentForProductIdentifier: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if ([transaction.payment.productIdentifier isEqualToString:self.productIdentifierToRestore] && self.delegate && [self.delegate respondsToSelector:@selector(productWithIdentifier:purchasedWithSuccess:error:)]) {
        [self.delegate productWithIdentifier:transaction.payment.productIdentifier purchasedWithSuccess:YES error:nil];
    }
}

- (void)failedTransaction:(SKPaymentTransaction*)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    if (self.delegate && [self.delegate respondsToSelector:@selector(productWithIdentifier:purchasedWithSuccess:error:)]) {
        [self.delegate productWithIdentifier:transaction.payment.productIdentifier purchasedWithSuccess:NO error:transaction.error.code == SKErrorPaymentCancelled ? nil : transaction.error];
    }
}

- (void)provideContentForProductIdentifier:(NSString *)productIdentifier
{
    [self.purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
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

#pragma mark - Public

- (BOOL)isProductPurchased:(NSString *)productIdentifier
{
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

#pragma mark - Purchasing

- (void)buyProduct:(SKProduct *)product
{
    NSLog(@"Buying %@", product.productIdentifier);
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restoreProductWithIdentifier:(NSString *)productIdentifier;
{
    self.productIdentifierToRestore = productIdentifier;
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
