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

static NSString * const pListName = @"SpecialisationPicsAndCode";

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;
@property (weak, nonatomic) IBOutlet UIButton *mySpecialisationsButton;
@property (weak, nonatomic) IBOutlet UIButton *moreSpecialisationsButton;

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSArray * specialisationsArray;
@property (strong, nonatomic) PESpecialisationManager * specManager;
@property (strong, nonatomic) NSArray *sortedArrayWithKeys;

@property (assign, nonatomic) BOOL isMyspecializations;

//@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];
    self.isMyspecializations = YES;
    
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
    
    /*
    //remove
    //1.create required entity
    Entity * obj;
    //2. create object description
    PEObjectDescription * objectToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Entity" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:@"hello24" ];
    //3. call to method
    [PECoreDataManager removeFromDB:objectToDelete withManagedObject:obj];
    
    //search all
    //1. create object description
    PEObjectDescription * searchObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Entity" withSortDescriptorKey:@"name"];
    //2. call to method with returned array
    NSArray * result2 = [PECoreDataManager getAllEntities:searchObject];
    //3. do some cool stuff with result
    for (Entity * item in result2){
        NSLog(@"Item is - %@", item.name);
        NSLog(@"Internal entity q-ty- %i", item.someEntity.count);
    }
    
    Entity * obj1;
    //2. create object description
    PEObjectDescription * objToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Entity" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:@"TODelete" ];
    //3. call to method
    [PECoreDataManager removeFromDB:objToDelete withManagedObject:obj1];
    */
    
//    Specialisation * spec;
//    PEObjectDescription * objToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:@"General"];
//    [PECoreDataManager removeFromDB:objToDelete withManagedObject:spec];
//    [self.collectionView reloadData];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.specialisationsArray = [PECoreDataManager getAllEntities:searchedObject];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
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
    self.specialisationsArray = [self allSpecs];
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
        NSLog(@"Selected specs - %@", ((PESpecialisationCollectionViewCell*)[collectionView cellForItemAtIndexPath:indexPath]).specName );
    }
}

#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.specialisationsArray && self.specialisationsArray.count > 0) {
            return self.specialisationsArray.count;
    } else {
        return 1;
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
            cell.specialisationIconImageView.image = [UIImage imageNamed:self.specialisationsArray[indexPath.row]];
            cell.specName = self.sortedArrayWithKeys[indexPath.row];
        }
    }
    return cell;
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

- (NSArray*) allSpecs
{
    NSMutableArray * arrayWithAllSpecsPhoto = [[NSMutableArray alloc] init];
    
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pListName ofType:@"plist" ]];
    
    NSArray * arrKeys = [pList allKeys];
    self.sortedArrayWithKeys = [arrKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * str1 = (NSString*)obj1;
        NSString * str2 = (NSString*)obj2;
        return [str1 compare:str2];
    }];
    
    for (int i=0; i<self.sortedArrayWithKeys.count; i++) {
        NSDictionary * dic = [pList valueForKey:arrKeys[i]];
        [arrayWithAllSpecsPhoto addObject:[dic valueForKey:@"photoName"]];
    }
    
    NSArray * sortedPics = [arrayWithAllSpecsPhoto sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSString * str1 = (NSString*)obj1;
        NSString * str2 = (NSString*)obj2;
        return [str1 compare:str2];
    }];
    
    return sortedPics;
}

- (NSArray*) avaliableSpecs
{
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    return [PECoreDataManager getAllEntities:searchedObject];
}

@end
