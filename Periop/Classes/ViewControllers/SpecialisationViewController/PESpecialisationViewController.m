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

#import "PEPlistParser.h"
#import "PESpecialisationManager.h"

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

#warning - JUST FOR CHECKING DATAMANAGER -TO DELETE
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
//@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@property (strong, nonatomic) NSArray * arrayWithSpecialisations;
@property (strong, nonatomic) PESpecialisationManager * manager;


@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.text = @"Specialisations";
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"PESpecialisationCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"SpecialisedCell"];
    
    self.collectionView.delegate= (id)self;
    self.collectionView.dataSource = (id)self;
    
    UIImageView * backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Background"]];
    self.collectionView.backgroundView = backgroundImage;
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.manager = [PESpecialisationManager sharedManager];
    
    PEObjectDescription * searchedObject = [[PEObjectDescription alloc] initWithSearchObject:self.managedObjectContext withEntityName:@"Specialisation" withSortDescriptorKey:@"name"];
    self.arrayWithSpecialisations = [PECoreDataManager getAllEntities:searchedObject];
   
    if (self.arrayWithSpecialisations.count>0){
        for (Specialisation * specs in self.arrayWithSpecialisations){
            NSLog(@"Spec name - %@", specs.name);
            NSLog(@"Spec id - %@", specs.specID);
            NSLog(@"Spec photo Name - %@", specs.photoName);
        }
    } else {
        PEPlistParser * parser = [[PEPlistParser alloc] init];
        [parser parsePList:@"General" specialisation:^(Specialisation *specialisation) {
            
        }];
    }
    
#warning - TO delete
    //singleton for dataManager
    //PECoreDataManager * dataManager = [PECoreDataManager sharedManager];
    //self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];

    /*
    //remove
    //1.create required entity
    Entity * obj;
    //2. create object description
    PEObjectDescription * objectToDelete = [[PEObjectDescription alloc] initWithDeleteObject:self.managedObjectContext withEntityName:@"Entity" withSortDescriptorKey:@"name" forKeyPath:@"name" withSortingParameter:@"hello24" ];
    //3. call to method
    [PECoreDataManager removeFromDB:objectToDelete withManagedObject:obj];

    //add
   
//    NSEntityDescription * entity1 = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];
//    NSManagedObject * item = [[NSManagedObject alloc] initWithEntity:entity1 insertIntoManagedObjectContext:self.managedObjectContext];
//    [item setValue:@"hello24" forKey:@"name"];
//    NSError * error2 =nil;
//    [item.managedObjectContext save:&error2];
    
    
    //create main entity
    NSEntityDescription * entity = [NSEntityDescription entityForName:@"Entity" inManagedObjectContext:self.managedObjectContext];
    Entity * newEntity = [[Entity alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    newEntity.name = @"Hello i;m entity with relationships";
    //create new same type entity
    Entity * oneMoreEntity = [[Entity alloc] initWithEntity:entity insertIntoManagedObjectContext:self.managedObjectContext];
    oneMoreEntity.name=@"internal entity";
    
    //create another entity
    NSEntityDescription * newSomeEntity = [NSEntityDescription entityForName:@"SomeEntity" inManagedObjectContext:self.managedObjectContext];
    SomeEntity * someNewEntity = [[SomeEntity alloc] initWithEntity:newSomeEntity insertIntoManagedObjectContext:self.managedObjectContext];
    someNewEntity.attribute = @"attribute1";
    someNewEntity.attribute1 = @"attribute2";
    someNewEntity.attribute2 = @"attribute3";
    
    //set relationship between all created entities
    [newEntity addSomeEntityObject:someNewEntity];
    [newEntity addThisEntityObject:oneMoreEntity];
    NSError * errosSave =nil;
    [newEntity.managedObjectContext save:&errosSave];
    
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
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender{
    [self.navigationBarLabel removeFromSuperview];
    
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = @"Specialisations";
    menuController.sizeOfFontInNavLabel = self.navigationBarLabel.font.pointSize;
    menuController.isButtonVisible = true;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height+self.buttonsView.frame.size.height;
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)mySpesialisationButton:(id)sender {
    NSLog(@"1");
}

- (IBAction)moreSpecialisationButton:(id)sender {
    NSLog(@"2");
}

#pragma mark - CollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    NSEntityDescription * specEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    self.manager.currentSpecialisation  = [[Specialisation alloc] initWithEntity:specEntity insertIntoManagedObjectContext:self.managedObjectContext];
    self.manager.currentSpecialisation = self.arrayWithSpecialisations[indexPath.row];
    
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.selectedViewController = rootController.viewControllers[5];
}


#pragma mark - CollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (self.arrayWithSpecialisations.count>0){
        return self.arrayWithSpecialisations.count;
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PESpecialisationCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpecialisedCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.imageCell.image = [UIImage imageNamed:((Specialisation*)self.arrayWithSpecialisations[indexPath.row]).photoName];
    return cell;
}



@end
