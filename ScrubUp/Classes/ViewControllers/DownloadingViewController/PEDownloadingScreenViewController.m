//
//  PEDownloadingScreenViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEDownloadingScreenViewController.h"
#import "PEPurchaseManager.h"
#import "PECsvParser.h"
#import "Procedure.h"
#import "Doctors.h"
#import "Specialisation.h"
#import "PEObjectDescription.h"
#import "PECoreDataManager.h"
#import "PEGAManager.h"

@interface PEDownloadingScreenViewController () <UIAlertViewDelegate, IAPurchaseDelegate>

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *logoImage;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (weak, nonatomic) PEPurchaseManager *purchaseManager;
@property (strong, nonatomic) NSString *productIdentifier;

@property (weak, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PEDownloadingScreenViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
    
    self.purchaseManager = [PEPurchaseManager sharedManager];
    self.productIdentifier = [self.specialisationInfo valueForKey:@"productIdentifier"];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.purchaseManager.delegate = (id)self;
    
    [self prepareForDownload];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self showView];
}

#pragma mark - Private

- (void)prepareForDownload
{
    if ([self.purchaseManager isProductPurchased:self.productIdentifier]) {
        if (self.isInitialConfig) {
            if ([self respondsToSelector:@selector(downloadData)]) {
                [self performSelector:@selector(downloadData) withObject:nil afterDelay:2.0f];
            }
        } else {
            [self prepareFoReset];
        }
    } else {
        [self prepareForBuying];
    }
}

- (void)prepareFoReset
{
    [[[UIAlertView alloc] initWithTitle:@"ScrubUp" message:@"You will loose all your data created. Do you wish to continue?" delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil] show];
}

- (void)prepareForBuying
{
    NSString *message = [NSString stringWithFormat:@"Would you like to purchase %@ for US$1.99?", [self.specialisationInfo valueForKey:@"name"]];
    [[[UIAlertView alloc] initWithTitle:@"ScrubUp" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Purchase", @"Restore", nil] show];
}

- (void)downloadData
{
    [self removePreviousData];
    
    if ([((NSString *)[self.specialisationInfo valueForKey:@"name"]) isEqualToString:@"General"]) {
        PECsvParser *parser = [[PECsvParser alloc] init];
        [parser parseCsvMainFile:@"General" csvToolsFile:@"General_Tools" specName:@"General"];
    } else {
        NSMutableArray *arrayWithPathToDelete = [[NSMutableArray alloc] init];
        NSData *dataMain = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.specialisationInfo valueForKey:@"urlDownloadingMain"]]];
        if (dataMain)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"mainSpec.csv"];
            if ([dataMain writeToFile:filePath atomically:YES]) {
                NSLog(@"mainSpec file created");
                [arrayWithPathToDelete addObject:filePath];
            }
        }
        NSData *dataTools = [NSData dataWithContentsOfURL:[NSURL URLWithString:[self.specialisationInfo valueForKey:@"urlDownloadingTool"]]];
        if (dataTools)
        {
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"toolSpec.csv"];
            if ([dataTools writeToFile:filePath atomically:YES]) {
                NSLog(@"toolSpec file created");
                [arrayWithPathToDelete addObject:filePath];
            }
        }
        
        PECsvParser *parser = [[PECsvParser alloc] init];
        [parser parseCsvMainFile:@"mainSpec" csvToolsFile:@"toolSpec" specName:[self.specialisationInfo valueForKey:@"name"]];
        
        for (int i = 0; i < arrayWithPathToDelete.count; i++) {
            NSError *error = nil;
            if (![[NSFileManager defaultManager] removeItemAtPath:arrayWithPathToDelete[i] error:&error]) {
                NSLog(@"Cant remove file after parsing - %@", error.localizedDescription);
            }
        }
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dataDidChanged)]) {
        [self.delegate dataDidChanged];
    }
    
    [self hideView];
    
    [[PEGAManager sharedManager] trackDownloadedSpecialisation:[self.specialisationInfo valueForKey:@"name"]];
}

- (void)removePreviousData
{
    NSLog(@"Finding spec...");
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *specEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:specEntity];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    NSLog(@"Done.\nFinding doctors for selected spec and removing existing relations... ");
    for (Specialisation *specToCheck in result) {
        for (Doctors *docToCheck in [specToCheck.doctors allObjects] ) {
            for (Specialisation *spec in [docToCheck.specialisation allObjects]) {
                if ([spec.name isEqualToString:[self.specialisationInfo valueForKey:@"name"]]) {
                    [docToCheck removeSpecialisationObject:spec];
                    if (![[docToCheck.specialisation allObjects] count]) {
                        [self.managedObjectContext deleteObject:docToCheck];
                    }
                }
            }
        }
    }
    
    NSLog(@"Done.\nFinding and remove selected spec...");
    Specialisation *spec;
    PEObjectDescription *objToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:[self.specialisationInfo valueForKey:@"name"]];
    [PECoreDataManager removeFromDB:objToDelete withManagedObject:spec];
    NSLog(@"Done.");
}

- (void)showView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.33;
    animation.fromValue = @0;
    animation.toValue = @1;
    animation.removedOnCompletion = YES;
    [self.view.layer addAnimation:animation forKey:nil];
    [self.activityIndicator startAnimating];
}

- (void)hideView
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animation.duration = 0.33;
    animation.fromValue = @1;
    animation.toValue = @0;
    animation.removedOnCompletion = NO;
    animation.delegate = self;
    [self.view.layer addAnimation:animation forKey:@"hide"];
    self.view.layer.opacity = 0;
}

- (void)setupUI
{
    self.logoImage.image = [UIImage imageNamed:[self.specialisationInfo valueForKey:@"logo"]];
    self.titleLabel.font = [UIFont fontWithName:FONT_MuseoSans500 size:17.5f];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dataDidChanged)]) {
            [self.delegate dataDidChanged];
        }
        [self hideView];
    } else if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Yes"]) {
        [self downloadData];
    } else if ([[alertView buttonTitleAtIndex:1] isEqualToString:@"Purchase"]) {
        [self downloadData];
        return;
        [self.purchaseManager requestProductsWithCompletitonHelper:^(BOOL success, NSArray *products) {
            if (success && products.count) {
                for (SKProduct *product in products) {
                    if ([product.productIdentifier isEqualToString:self.productIdentifier]) {
                        [self.purchaseManager buyProduct:product];
                        break;
                    }
                }
            } else {
                [[[UIAlertView alloc] initWithTitle:@"ScrubUp" message:@"Failed connect to iTunes Store." delegate:self cancelButtonTitle:@"Close" otherButtonTitles:nil] show];
            }
        }];
    } else if ([[alertView buttonTitleAtIndex:2] isEqualToString:@"Restore"]) {
        [self.purchaseManager restoreProductWithIdentifier:self.productIdentifier];
    }
}

#pragma mark - Animations delegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.view.layer animationForKey:@"hide"]) {
        [self.view.layer removeAnimationForKey:@"hide"];
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - IAPurchaseDelegate

- (void)productWithIdentifier:(NSString *)productIdentifier purchasedWithSuccess:(BOOL)success error:(NSError *)error
{
    if (success) {
        [self downloadData];
    } else {
        if (error) {
            NSString *message = [NSString stringWithFormat:@"%@ could not be purchased at this time. Please try again later.", [self.specialisationInfo valueForKey:@"name"]];
            [[[UIAlertView alloc] initWithTitle:@"Transaction failed" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        } else {
            [self hideView];
        }
    }
}

@end
