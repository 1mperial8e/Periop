//
//  PESpecializationViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESpecialisationViewController.h"
#import "PESpecialisationCollectionViewCell.h"
#import "PEProcedureListViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PECoreDataManager.h"
#import "PECsvParser.h"
#import "PEPlistParser.h"
#import "PESpecialisationManager.h"
#import "PEObjectDescription.h"
#import "PETutorialViewController.h"
#import "PEPurchaseManager.h"
#import <StoreKit/StoreKit.h>

static NSString * const SVCPListName = @"SpecialisationPicsAndCode";

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *mySpecialisationsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreSpecialisationsButton;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSArray * specialisationsArray;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSMutableDictionary *moreSpecialisationSpecs;
@property (strong, nonatomic) NSMutableDictionary *identifiers;
@property (assign, nonatomic) BOOL isMyspecializations;
@property (copy, nonatomic) NSString *selectedSpecToReset;
@property (strong, nonatomic) PEPurchaseManager *purchaseManager;

//@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moreSpecialisationButton:) name:@"moreSpecButton" object: nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mySpesialisationButton:) name:@"mySpecButton" object: nil];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.text = @"Specialisations";
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.numberOfLines = 0;
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PESpecialisationCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"SpecialisedCell"];
    
    self.collectionView.delegate= (id)self;
    self.collectionView.dataSource = (id)self;
    
    UIImageView * backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    self.collectionView.backgroundView = backgroundImage;
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    [self initWithData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.specialisationsArray = [PECoreDataManager getAllEntities:searchedObject];
    [self.collectionView reloadData];
    if (self.specManager.currentProcedure!=nil) {
        self.specManager.currentProcedure = nil;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (NSUInteger) supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    [self.navigationBarLabel removeFromSuperview];
    
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = @"Specialisations";
    menuController.sizeOfFontInNavLabel = self.navigationBarLabel.font.pointSize;
    menuController.isButtonMySpecializations = self.isMyspecializations;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height+self.buttonsView.frame.size.height;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)mySpesialisationButton:(id)sender
{
    self.isMyspecializations = YES;
    [self.mySpecialisationsButton setImage:[UIImage imageNamed:@"My_Specialisations_Active"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamed:@"More_Specialisations_Inactive"] forState:UIControlStateNormal];
    self.specialisationsArray = [self avaliableSpecs];
    [self.collectionView reloadData];
}

- (IBAction)moreSpecialisationButton:(id)sender
{
    self.isMyspecializations = NO;
    [self.mySpecialisationsButton setImage:[UIImage imageNamed:@"My_Specialisations_Inactive"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamed:@"More_Specialisations_Active"] forState:UIControlStateNormal];
    [self allSpecs];
    [self allIdentifiers];
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
            NSString * message = [NSString stringWithFormat:@"Do you really want to reset all settings in %@ specialisation?", ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName];
            self.selectedSpecToReset = ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName;
            UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:@"Redownload" message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
            [alerView show];
        } else {
            [self.purchaseManager requestProductsWithCompletitonHelper:^(BOOL success, NSArray *products) {
                if (success) {
                    NSString * requestedProductIdentifier = ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).productIdentifier;
                    for (SKProduct * product in products) {
                        if ([product.productIdentifier isEqualToString:requestedProductIdentifier]) {
                            [self.purchaseManager buyProduct:product];
                            if ([self.purchaseManager productPurchased:product.productIdentifier]) {
                                NSLog(@"start to update DB with new spec...");
                                //to download new specs
                            }
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
        return [self.moreSpecialisationSpecs allKeys].count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PESpecialisationCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpecialisedCell" forIndexPath:indexPath];
    if (self.specialisationsArray && self.specialisationsArray.count > 0) {
        cell.backgroundColor = [UIColor clearColor];
        
        if (self.isMyspecializations) {
            cell.specialisationIconImageView.image = [UIImage imageNamed:((Specialisation*)self.specialisationsArray[indexPath.row]).photoName];
            cell.specName = ((Specialisation*)self.specialisationsArray[indexPath.row]).name;
        } else {
            NSArray * all = [[self.moreSpecialisationSpecs allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSString * str1 = (NSString*)obj1;
                NSString * str2 = (NSString*)obj2;
                return [str1 compare:str2];
            }];
            cell.specialisationIconImageView.image = [UIImage imageNamed:[self.moreSpecialisationSpecs valueForKey:all[indexPath.row]]];
            cell.specName = all[indexPath.row];
            cell.productIdentifier = [self.identifiers valueForKey:all[indexPath.row]];;
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
            NSLog(@"Finding and remove selected spec...");
            Specialisation * spec;
            PEObjectDescription * objToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:self.selectedSpecToReset];
            [PECoreDataManager removeFromDB:objToDelete withManagedObject:spec];
            
            NSLog(@"Parsing selected spec and update DB...");
            PECsvParser * parser = [[PECsvParser alloc] init];
            NSString * toolsString = [NSString stringWithFormat:@"%@_Tools", self.selectedSpecToReset];
            [parser parseCsv:self.selectedSpecToReset withCsvToolsFileName:toolsString];
            self.selectedSpecToReset = nil;
            [self initWithData];
            [self.collectionView reloadData];
            
            NSLog(@"Done successfuly!");
        }
    }
}

#pragma mark - Private

- (void)initWithData
{
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.specialisationsArray = [PECoreDataManager getAllEntities:searchedObject];
    if (self.specialisationsArray.count <= 0) {
        PECsvParser * parser = [[PECsvParser alloc] init];
        [parser parseCsv:@"General" withCsvToolsFileName:@"General_Tools"];
        
//        PEPlistParser * parser = [[PEPlistParser alloc] init];
//        [parser parsePList:@"General" specialisation:^(Specialisation *specialisation) {
//        }];
//        [parser parsePList:@"Cardiothoracic" specialisation:^(Specialisation *specialisation) {
//        }];
        
        self.specialisationsArray = [PECoreDataManager getAllEntities:searchedObject];
        [self.collectionView reloadData];
    }
}

- (void) allSpecs
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    NSArray * arrKeys = [pList allKeys];
    NSMutableArray * arrayWithAllSpecsPhoto = [[NSMutableArray alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        NSDictionary *dic = [pList valueForKey:arrKeys[i]];
        [arrayWithAllSpecsPhoto addObject:[dic valueForKey:@"photoName"]];
    }
    self.moreSpecialisationSpecs = [[NSMutableDictionary alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        [self.moreSpecialisationSpecs setValue:arrayWithAllSpecsPhoto[i] forKey:arrKeys[i]];
    }
}

- (void) allIdentifiers
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist" ]];
    NSArray * arrKeys = [pList allKeys];
    NSMutableArray * arrayWithAllIdentifiers = [[NSMutableArray alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        NSDictionary *dic = [pList valueForKey:arrKeys[i]];
        [arrayWithAllIdentifiers addObject:[dic valueForKey:@"productIdentifier"]];
    }
    self.identifiers = [[NSMutableDictionary alloc] init];
    for (int i=0; i<arrKeys.count; i++) {
        [self.identifiers setValue:arrayWithAllIdentifiers[i] forKey:arrKeys[i]];
    }
}

- (NSArray*) avaliableSpecs
{
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    return [PECoreDataManager getAllEntities:searchedObject];
}

@end
