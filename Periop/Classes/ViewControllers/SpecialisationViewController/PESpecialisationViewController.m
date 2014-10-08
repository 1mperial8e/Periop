//
//  PESpecializationViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const SVCPListName = @"SpecialisationPicsAndCode";
static NSString *const SVCSpecialisations = @"Specialisations";
static NSString *const SVCRestoreKeySetting = @"Restored";

static NSString *const SVCSpecialisationCollectionCellNibName = @"PESpecialisationCollectionCell";
static NSString *const SVCSpecialisationCollectionCellIdentifier = @"SpecialisedCell";

#import "PESpecialisationViewController.h"
#import "PESpecialisationCollectionViewCell.h"
#import "PEProcedureListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PECoreDataManager.h"
#import "PECsvParser.h"
#import "PESpecialisationManager.h"
#import "PEObjectDescription.h"
#import "PETutorialViewController.h"
#import "PEPurchaseManager.h"
#import <StoreKit/StoreKit.h>
#import "UIImage+ImageWithJPGFile.h"

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate, SpecialisationListDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *mySpecialisationsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreSpecialisationsButton;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSArray *specialisationsArray;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSMutableDictionary *moreSpecialisationSpecs;
@property (assign, nonatomic) BOOL isMyspecializations;
@property (copy, nonatomic) NSString *selectedSpecToReset;
@property (strong, nonatomic) PEPurchaseManager *purchaseManager;

//@property (strong, nonatomic) NSArray *avaliableSKProductsForPurchasing;

@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self downloadPurchasedItems:@"" withToolsPartFile:@"" withSpecName:@"Gyneacology"];
    
    self.purchaseManager = [PEPurchaseManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    self.isMyspecializations = YES;
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    if (![def integerForKey:TVCShowTutorial]) {
        PETutorialViewController *tutorialController = [[PETutorialViewController alloc] initWithNibName:@"PETutorialViewController" bundle:nil];
        UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
        [rootController presentViewController:tutorialController animated:NO completion:nil];
    }
    
    if (![def integerForKey:SVCRestoreKeySetting]){
         [self.purchaseManager restoreCompleteTransactions];
        [def setInteger:1 forKey:SVCRestoreKeySetting];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:SVCSpecialisationCollectionCellNibName bundle:nil] forCellWithReuseIdentifier:SVCSpecialisationCollectionCellIdentifier];
    
    self.collectionView.delegate = (id)self;
    self.collectionView.dataSource = (id)self;
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamedFile:@"Background"]];
    self.collectionView.backgroundView = backgroundImage;
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = SVCSpecialisations;
    
    PEObjectDescription *searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.specialisationsArray = [PECoreDataManager getAllEntities:searchedObject];
    [self initWithData];
    [self.collectionView reloadData];
    
    if (self.specManager.currentProcedure!=nil) {
        self.specManager.currentProcedure = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = SVCSpecialisations;
    menuController.isButtonMySpecializations = self.isMyspecializations;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height+self.buttonsView.frame.size.height;
    menuController.delegate = (id)self;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)mySpesialisationButton:(id)sender
{
    self.isMyspecializations = YES;
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Active"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Inactive"] forState:UIControlStateNormal];
    self.specialisationsArray = [self avaliableSpecs];
    [self.collectionView reloadData];
}

- (IBAction)moreSpecialisationButton:(id)sender
{
    self.isMyspecializations = NO;
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Inactive"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Active"] forState:UIControlStateNormal];
   // [self refreshData];
    [self.collectionView reloadData];
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMyspecializations) {
        self.specManager.currentSpecialisation = self.specialisationsArray[indexPath.row];
        PEProcedureListViewController *procedureListController = [[PEProcedureListViewController alloc] initWithNibName:@"PEProcedureListViewController" bundle:nil];
        [self.navigationController pushViewController:procedureListController animated:YES];
    } else {
        NSLog(@"Selected specs - %@, identifier - %@", ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName,((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).productIdentifier);
        
        NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
        if ([def integerForKey: ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).productIdentifier]) {
            NSString *message = [NSString stringWithFormat:@"Do you really want to reset all settings in %@ specialisation?", ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName];
            self.selectedSpecToReset = ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName;
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Reset" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alerView show];
        } else {

            [self.purchaseManager requestProductsWithCompletitonHelper:^(BOOL success, NSArray *products) {
                if (success) {
                    NSString *requestedProductIdentifier = ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).productIdentifier;
                    for (SKProduct *product in products) {
                        if ([product.productIdentifier isEqualToString:requestedProductIdentifier]) {
                            NSLog(@"Start buying...");
                            [self.purchaseManager buyProduct:product];
                        }
                    }
                }
            }];            
        }
    }
}

#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isMyspecializations) {
        return self.specialisationsArray.count;
    } else {
       // return self.avaliableSKProductsForPurchasing.count;
        return [self returnQuantityOfAvaliableSpecs];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PESpecialisationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SVCSpecialisationCollectionCellIdentifier forIndexPath:indexPath];
    if (self.specialisationsArray && self.specialisationsArray.count) {
        cell.backgroundColor = [UIColor clearColor];
        
        if (self.isMyspecializations) {
            cell.specialisationIconImageView.image = [UIImage imageNamedFile:((Specialisation*)self.specialisationsArray[indexPath.row]).photoName];
            cell.specName = ((Specialisation*)self.specialisationsArray[indexPath.row]).name;
        } else {
            
            NSDictionary *plistToParse = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist"]];
            NSArray *arrKeys = [[plistToParse allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString *specName1 = (NSString *)obj1;
                NSString *specName2 = (NSString *)obj2;
                return [specName1 compare:specName2];
            }];
            
            for (int i = 0; i < arrKeys.count; i++) {
                if (i == indexPath.row) {
                    NSDictionary *dic = [plistToParse valueForKey:arrKeys[i]];
                    cell.productIdentifier = [dic valueForKey:@"productIdentifier"];
                    cell.specialisationIconImageView.image = [UIImage imageNamedFile:[dic valueForKey:@"photoName"]];
                    cell.specName = arrKeys[i];
                }
            }
            
//            NSArray *allProducts = [self.avaliableSKProductsForPurchasing sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                NSString *product1 = ((SKProduct*)obj1).localizedTitle;
//                NSString *product2 = ((SKProduct*)obj2).localizedTitle;
//                return [product1 compare:product2];
//            }];
//            cell.productIdentifier = ((SKProduct*)allProducts[indexPath.row]).productIdentifier;
//            cell.specialisationIconImageView.image = [UIImage imageNamedFile:[self getFotoForSKProduct:(SKProduct*)allProducts[indexPath.row]]];
        }
    }
    return cell;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (!buttonIndex) {
        NSLog(@"canceled");
    } else {
        if (self.selectedSpecToReset!=nil) {

            NSLog(@"Finding docotrs for selected spec and removing existing relations...");
            for (Specialisation *specToCheck in [self avaliableSpecs]) {
                for (Doctors *docToCheck in [specToCheck.doctors allObjects] ) {
                    for (Specialisation *spec in [docToCheck.specialisation allObjects]) {
                        if ([spec.name isEqualToString:self.selectedSpecToReset]) {
                            [docToCheck removeSpecialisationObject:spec];
                            if (![[docToCheck.specialisation allObjects] count]) {
                                [self.managedObjectContext deleteObject:docToCheck];
                            }
                        }
                    }
                }
            }
            
            NSLog(@"Finding and remove selected spec...");
            Specialisation *spec;
            PEObjectDescription *objToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:self.selectedSpecToReset];
            [PECoreDataManager removeFromDB:objToDelete withManagedObject:spec];
            
            NSLog(@"Parsing selected spec and update DB...");
            [self restoreSelectedSpecByName:self.selectedSpecToReset];
            self.selectedSpecToReset = nil;
            [self.collectionView reloadData];
            
            NSLog(@"Done successfuly!");
        }
    }
}

#pragma mark - Private

- (NSInteger)returnQuantityOfAvaliableSpecs
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    return [pList allKeys].count;
}

- (void)initWithData
{
    self.specialisationsArray = [self avaliableSpecs];
    if (!self.specialisationsArray.count) {
        PECsvParser *parser = [[PECsvParser alloc] init];
        [parser parseCsvMainFile:@"General" csvToolsFile:@"General_Tools" specName:@"General"];
        
        self.specialisationsArray = [self avaliableSpecs];
        [self.collectionView reloadData];
    }
}

- (void) allSpecs
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    NSArray *arrKeys = [pList allKeys];
    NSMutableArray *arrayWithAllSpecsPhoto = [[NSMutableArray alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        NSDictionary *dic = [pList valueForKey:arrKeys[i]];
        [arrayWithAllSpecsPhoto addObject:[dic valueForKey:@"photoName"]];
    }
    self.moreSpecialisationSpecs = [[NSMutableDictionary alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        [self.moreSpecialisationSpecs setValue:arrayWithAllSpecsPhoto[i] forKey:arrKeys[i]];
    }
}

- (NSArray*) avaliableSpecs
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];

    NSEntityDescription *specEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:specEntity];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return result;
}

- (void)restoreSelectedSpecByName: (NSString*)specName
{
    if ([specName isEqualToString:@"General"]) {
       [self downloadPurchasedItems:@"General" withToolsPartFile:@"General_Tools" withSpecName:specName];
    } else {
        NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
        
        NSArray *arrKeys = [pList allKeys];
        NSString *purchasedSpecURLAll;
        NSString *purchasedSpecURLTools;
        for (int i =0; i<arrKeys.count; i++) {
            if ([arrKeys[i] isEqualToString:specName]) {
                NSDictionary *dic = [pList valueForKey:arrKeys[i]];
                purchasedSpecURLAll = [dic valueForKeyPath:@"urlDownloadingMain"];
                purchasedSpecURLTools = [dic valueForKeyPath:@"urlDownloadingTool"];
                [self downloadPurchasedItems:purchasedSpecURLAll withToolsPartFile:purchasedSpecURLTools withSpecName:specName];
            }
        }
    }
}

#pragma mark - InAppPurchase

//- (void)refreshData
//{
//    self.avaliableSKProductsForPurchasing = nil;
//    [self.purchaseManager requestProductsWithCompletitonHelper:^(BOOL success, NSArray *products) {
//        if (success) {
//            self.avaliableSKProductsForPurchasing = products;
//            [self.collectionView reloadData];
//        }
//    }];
//}

- (NSString*)getFotoForSKProduct :(SKProduct*)skProduct
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    
    NSArray *arrKeys = [pList allKeys];
    NSString *photoName;
    for (int i =0; i<arrKeys.count; i++) {
        NSDictionary *dic = [pList valueForKey:arrKeys[i]];
        if ([[dic valueForKey:@"productIdentifier"] isEqualToString:skProduct.productIdentifier]) {
            photoName = [dic valueForKey:@"photoName"];
        }
    }
    return photoName;
}

#pragma mark - NotificationFromPurchaseManager

- (void)productPurchased: (NSNotification *)notification
{
    //product identifier - purchased product
    NSString *productIdentifier = notification.object;
    
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    
    NSArray *arrKeys = [pList allKeys];
    NSString *purchasedSpecURLAll;
    NSString *purchasedSpecURLTools;
    for (int i =0; i<arrKeys.count; i++) {
        NSDictionary *dic = [pList valueForKey:arrKeys[i]];
        if ([[dic valueForKey:@"productIdentifier"] isEqualToString:productIdentifier]) {
            purchasedSpecURLAll = [dic valueForKeyPath:@"urlDownloadingMain"];
            purchasedSpecURLTools = [dic valueForKeyPath:@"urlDownloadingTool"];
            [self downloadPurchasedItems:purchasedSpecURLAll withToolsPartFile:purchasedSpecURLTools withSpecName:arrKeys[i]];
        }
    }
}

- (void)downloadPurchasedItems:(NSString*)mainFilePart withToolsPartFile:(NSString*)toolsFilePart withSpecName:(NSString*)specName;
{
  // toolsFilePart = @"https://docs.google.com/uc?export=download&id=0B1GU18BxUf8hUG5yYzVEUTdMVm8";
  // mainFilePart = @"https://docs.google.com/uc?export=download&id=0B1GU18BxUf8hM1I3SldxODEzdUk";
    
    NSMutableArray *arrayWithPathToDelete = [NSMutableArray new];
    
    NSData *dataMain = [NSData dataWithContentsOfURL:[NSURL URLWithString:mainFilePart]];
    if ( dataMain )
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory,@"mainSpec.csv"];
        if ([dataMain writeToFile:filePath atomically:YES]) {
            NSLog(@"mainSpec file created");
            [arrayWithPathToDelete addObject:filePath];
        }
    }
    NSData *dataTools = [NSData dataWithContentsOfURL:[NSURL URLWithString:toolsFilePart]];
    if ( dataTools )
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
    [parser parseCsvMainFile:@"mainSpec" csvToolsFile:@"toolSpec" specName:specName];
    
    for (int i=0; i<arrayWithPathToDelete.count; i++) {
        NSError *error = nil;
        if (![[NSFileManager defaultManager] removeItemAtPath:arrayWithPathToDelete[i] error:&error]) {
            NSLog(@"Cant remove file after parsing - %@", error.localizedDescription);
        }
    }
}

#pragma mark - SpecialisationListDelegate

- (void)specialisationsListChanged:(PESpecList)specList
{
    switch (specList) {
        case PESpecListMySpecialisations:
            [self mySpesialisationButton:self];
            break;
        default:
            [self moreSpecialisationButton:self];
            break;
    }
}

@end
