//
//  IAPHelper.m
//  InAppRage
//
//  Created by Kirill on 9/15/14.
//  Copyright (c) 2014 Kirill. All rights reserved.
//

#import "IAPHelper.h"
//use StoreKit to access to In-App Purchases API
#import <StoreKit/StoreKit.h>

NSString * const  IAPHelperProductPurchasedNotification = @"IAHelperProductPurchaseNotification";

//implement this protocl for receiving list of product from StoreKit
@interface IAPHelper() <SKProductsRequestDelegate, SKPaymentTransactionObserver>

//for storig SkStoreRequest
@property (strong, nonatomic) SKProductsRequest * productRequest;
//tracking on list of products requests and on list of products that already was purchased
@property (strong, nonatomic) RequestProductCompletitionHandler completitionHadler;

@property (strong, nonatomic) NSSet* productIdentifiers;
@property (strong, nonatomic) NSMutableSet * purchasedProductIdentifiers;

@end

@implementation IAPHelper

#pragma mark - Singleton

//custom initializer

- (id)initWithProductsIdentifieer:(NSSet *)productsIdentifier{
    if (self = [super init]){
        //store Product Identifiers
        self.productIdentifiers = productsIdentifier;
        
        //check the previously purchased identifiers on NSUserDefaults
        //create empty set
        self.purchasedProductIdentifiers = [NSMutableSet set];
        for (NSString * prodIdentifier in self.productIdentifiers){
            BOOL productPurchased = [[NSUserDefaults standardUserDefaults] boolForKey:prodIdentifier];
            if (productPurchased){
                [self.purchasedProductIdentifiers addObject:prodIdentifier];
                NSLog(@"Prev purchased: %@", prodIdentifier);
            } else {
                NSLog(@"Not purchased %@", prodIdentifier);
            }
        }
    }
    //add observer to get infor when some action with payment was done or no
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    return self;
}

//return array of existing items
- (void) requestProductsWithCompletitonHelper:(RequestProductCompletitionHandler)completitionHandler{
    self.completitionHadler = [completitionHandler copy];
    self.productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:self.productIdentifiers];
    self.productRequest.delegate = self;
    [self.productRequest start];
}

#pragma mark - SKProductsRequestDelegate 

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    NSLog(@"Loading list of products...");
    self.productRequest = nil;
    
    NSArray * skProducts = response.products;
    for (SKProduct * skProduct in skProducts){
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
    for (SKPaymentTransaction * transaction in transactions)
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
            }
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction*)transaction{
    NSLog(@"complete transaction");
    [self provideContentForProductIdentifier: transaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction*)transaction{
    NSLog(@"restore transaction");
    [self provideContentForProductIdentifier: transaction.originalTransaction.payment.productIdentifier];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)failedTransaction: (SKPaymentTransaction*)transaction{
    NSLog(@"failed transaction");
    if (transaction.error.code !=SKErrorPaymentCancelled){
        NSLog(@"Transaction error: %@", transaction.error.localizedDescription);
    }
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void) provideContentForProductIdentifier: (NSString*)productIdentifier{
    [self.purchasedProductIdentifiers addObject:productIdentifier];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:productIdentifier];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:IAPHelperProductPurchasedNotification object:productIdentifier userInfo:nil];
}


#pragma mark - PriceFormatter 

//formate price string
- (NSString* ) getFormattedLocalePrice : (SKProduct * )product{
    NSNumberFormatter * numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:product.priceLocale];
    NSString * formattedPrice = [numberFormatter stringFromNumber:product.price];
    return formattedPrice;
}

#pragma mark - Purchasing

//check if product is already in purchased list
- (BOOL) productPurchased:(NSString *)productIdentifier{
    return [self.purchasedProductIdentifiers containsObject:productIdentifier];
}

//buy product
- (void) buyProduct:(SKProduct *)product{
    NSLog(@"Buying %@", product.productIdentifier);
    SKPayment * payment = [SKPayment paymentWithProduct:product];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark - Restoring Old Purchases for Current Account

//restore previously purchased
- (void)restoreCompleteTransactions{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

@end
