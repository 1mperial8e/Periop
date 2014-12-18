//
//  PESpecializationViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESpecialisationViewController.h"
#import "PESpecialisationCollectionViewCell.h"
#import "PEProcedureListViewController.h"
#import "PESpecialisationManager.h"
#import "PEObjectDescription.h"
#import "PETutorialViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PEDownloadingScreenViewController.h"
#import "PECoreDataManager.h"
#import "PEInternetStatusChecker.h"
#import "PEGAManager.h"

#import "PEImageDownloaderManager.h"

static NSString *const SVCPriceForSpec = @"US $1,99";
static NSString *const SVCPListName = @"SpecialisationPicsAndCode";
static NSString *const SVCSpecialisations = @"Specialisations";
static NSString *const SVCSpecialisationCollectionCellNibName = @"PESpecialisationCollectionCell";
static NSString *const SVCSpecialisationCollectionCellIdentifier = @"SpecialisedCell";

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, SpecialisationListDelegate, PETutorialDelegate, PEDownloadingVCDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *mySpecialisationsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreSpecialisationsButton;

@property (strong, nonatomic) NSArray *mySpecialisationsInfo;
@property (strong, nonatomic) NSArray *moreSpecialisationsInfo;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSMutableDictionary *moreSpecialisationSpecs;
@property (assign, nonatomic) BOOL isMyspecializations;
@property (strong, nonatomic) NSUserDefaults *defaults;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PEImageDownloaderManager *imageManager;

@property (assign, nonatomic) BOOL internetActive;

@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.imageManager = [PEImageDownloaderManager sharedManager];

    self.isMyspecializations = YES;
    
    self.defaults = [NSUserDefaults standardUserDefaults];
    if (![self.defaults integerForKey:TVCShowTutorial]) {
        PETutorialViewController *tutorialController = [[PETutorialViewController alloc] initWithNibName:@"PETutorialViewController" bundle:nil];
        UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
        rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
#ifdef __IPHONE_8_0
        tutorialController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif        
        tutorialController.delegate = self;
        [rootController presentViewController:tutorialController animated:NO completion:nil];
    }
    
    [self.collectionView registerNib:[UINib nibWithNibName:SVCSpecialisationCollectionCellNibName bundle:nil] forCellWithReuseIdentifier:SVCSpecialisationCollectionCellIdentifier];
    
    [self.view insertSubview:[[UIImageView alloc] initWithImage:[UIImage imageNamedFile:@"Background"]] atIndex:0];
    
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = SVCSpecialisations;
    [self setSpecialisationsData];
    [self.collectionView reloadData];
    if (self.mySpecialisationsInfo.count > 1) {
        [self.imageManager startBackgroundAsyncImageDownloading];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self removeNotifications];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - Notifications

- (void)removeNotifications
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *exception) {
        NSLog(@"Cant remove observers from spec vc - %@", exception.debugDescription);
    }
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = SVCSpecialisations;
    menuController.isButtonMySpecializations = self.isMyspecializations;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height + self.buttonsView.frame.size.height;
    menuController.delegate = (id)self;
#ifdef __IPHONE_8_0
    menuController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)mySpesialisationButton:(id)sender
{
    self.isMyspecializations = YES;
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Active"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Inactive"] forState:UIControlStateNormal];
    self.mySpecialisationsInfo = [self avaliableSpecs];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (IBAction)moreSpecialisationButton:(id)sender
{
    self.isMyspecializations = NO;
    [self.mySpecialisationsButton setImage:[UIImage imageNamedFile:@"My_Specialisations_Inactive"] forState:UIControlStateNormal];
    [self.moreSpecialisationsButton setImage:[UIImage imageNamedFile:@"More_Specialisations_Active"] forState:UIControlStateNormal];
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMyspecializations) {
        self.specManager.currentSpecialisation = [self getSpecialisationWithID:[self.mySpecialisationsInfo[indexPath.row] valueForKey:@"specID"]];
        PEProcedureListViewController *procedureListController = [[PEProcedureListViewController alloc] initWithNibName:@"PEProcedureListViewController" bundle:nil];
        [self collectLikeDataForSpeciality:self.specManager.currentSpecialisation.name];
        [self.navigationController pushViewController:procedureListController animated:YES];
    } else {
        if ([PEInternetStatusChecker isInternetAvaliable]) {
            PEDownloadingScreenViewController *downloadingVC = [[PEDownloadingScreenViewController alloc] initWithNibName:@"PEDownloadingScreenViewController" bundle:nil];
            downloadingVC.specialisationInfo = self.moreSpecialisationsInfo[indexPath.row];
#ifdef __IPHONE_8_0
            downloadingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
            downloadingVC.delegate = self;
            UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [self collectLikeDataForSpeciality:[self.moreSpecialisationsInfo[indexPath.row] valueForKey:@"name"]];
            [rootController presentViewController:downloadingVC animated:NO completion:nil];
        } else {
            [self showAlertNoInternetConnection];
        }
    }
}

#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isMyspecializations) {
        return self.mySpecialisationsInfo.count;
    } else {
        return self.moreSpecialisationsInfo.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PESpecialisationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:SVCSpecialisationCollectionCellIdentifier forIndexPath:indexPath];
    if (self.isMyspecializations) {
        cell.specialisationIconImageView.image = [UIImage imageNamedFile:[self.mySpecialisationsInfo[indexPath.row] valueForKey:@"photoName"]];
        cell.labelPrice.hidden = YES;
    } else {
        cell.labelPrice.hidden = NO;
        cell.specialisationIconImageView.image = [UIImage imageNamedFile:[self.moreSpecialisationsInfo[indexPath.row] valueForKey:@"photoName"]];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:[self.moreSpecialisationsInfo[indexPath.row] valueForKey:@"productIdentifier"]]) {
            cell.labelPrice.hidden = YES;
        }
    }
    cell.labelPrice.text = SVCPriceForSpec;
    return cell;
}

#pragma mark - Statistics Google Analytics

- (void)collectLikeDataForSpeciality:(NSString *)specialisationName
{
    if ([PEInternetStatusChecker isInternetAvaliable]) {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:specialisationName]) {
            NSInteger likeCount = [[[NSUserDefaults standardUserDefaults] valueForKey:specialisationName] integerValue];
            likeCount++;
            for (int i = 0; i < likeCount; i++) {
                [[PEGAManager sharedManager] trackSelectionOfSpecialisation:specialisationName];
            }
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:specialisationName];
        } else  {
            [[PEGAManager sharedManager] trackSelectionOfSpecialisation:specialisationName];
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] valueForKey:specialisationName]) {
            NSInteger likeCount = [[[NSUserDefaults standardUserDefaults] valueForKey:specialisationName] integerValue];
            likeCount++;
            [[NSUserDefaults standardUserDefaults] setValue:@(likeCount) forKey:specialisationName];
        } else {
            [[NSUserDefaults standardUserDefaults] setValue:@(1) forKey:specialisationName];
        }
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Private

- (Specialisation *)getSpecialisationWithID:(NSString *)specID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *specEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:specEntity];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (Specialisation *spec in result) {
        if ([spec.specID isEqualToString:specID]) {
            return spec;
        }
    }
    
    return nil;
}

- (void)setSpecialisationsData
{
    self.mySpecialisationsInfo = [self avaliableSpecs];
    self.moreSpecialisationsInfo = [self getSortedSpecialisationsInfo];
    if (!self.mySpecialisationsInfo.count) {
        [self createDatabase];
        self.mySpecialisationsInfo = [self avaliableSpecs];
    }
}

- (NSArray *)avaliableSpecs
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *specEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:specEntity];
    NSError *error = nil;
    NSArray *result = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSArray *allSpecs = [self getSortedSpecialisationsInfo];
    
    NSMutableArray *sortedAvailableSpecs = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in allSpecs) {
        NSString *specID = [dict valueForKey:@"specID"];
        for (Specialisation *spec in result) {
            if ([spec.specID isEqualToString:specID]) {
                [sortedAvailableSpecs addObject:dict];
                break;
            }
        }
    }
    return sortedAvailableSpecs;
}

- (NSArray *)getSortedSpecialisationsInfo
{
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SVCPListName ofType:@"plist"]];
    NSArray *sortedKeys = [[pList allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString *)obj1 compare:(NSString *)obj2];
    }];
    NSMutableArray *sortedSpecialisationsInfo = [[NSMutableArray alloc] init];
    for (NSString *key in sortedKeys) {
        [sortedSpecialisationsInfo addObject:[pList valueForKey:key]];
    }
    return sortedSpecialisationsInfo;
}

- (void)createDatabase
{
    PEDownloadingScreenViewController *downloadingVC = [[PEDownloadingScreenViewController alloc] initWithNibName:@"PEDownloadingScreenViewController" bundle:nil];
    
    for (NSDictionary *specPList in self.moreSpecialisationsInfo) {
        if ([[specPList valueForKey:@"name"] isEqualToString:@"General"]){
            downloadingVC.specialisationInfo = specPList;
            downloadingVC.isInitialConfig = YES;
#ifdef __IPHONE_8_0
            downloadingVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
            downloadingVC.delegate = self;
            UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
            rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
            [rootController presentViewController:downloadingVC animated:NO completion:nil];
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

#pragma mark - PETutorialDelegate

- (void)tutorialDidFinished
{
    [self createDatabase];
}

#pragma mark - PEDownloadingVCDelegate

- (void)dataDidChanged
{
    [self setSpecialisationsData];
    [self.collectionView reloadData];
}

#pragma mark - AlertView

- (void)showAlertNoInternetConnection
{
    [[[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"To purchase this specialisation, you must connect to Internet. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}


@end
