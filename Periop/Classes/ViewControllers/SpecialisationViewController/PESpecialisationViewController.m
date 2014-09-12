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

#warning - JUST FOR CHECKING DATAMANAGER -TO DELETE
#import "PECoreDataManager.h"
#import "SomeEntity.h"
#import "Entity.h"
#import "PEObjectDescription.h"

@interface PESpecialisationViewController () <UICollectionViewDelegate, UICollectionViewDataSource, NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *buttonsView;

#warning - JUST FOR CHECKING DATAMANAGER -TO DELETE
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@end

@implementation PESpecialisationViewController

#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    //add label to navigation Bar
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    //set text aligment - center
    navigationLabel.textAlignment = NSTextAlignmentCenter;

    navigationLabel.text = @"Specialisations";
    navigationLabel.textColor = [UIColor whiteColor];
    //background
    navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel = navigationLabel;
    
    //create button for menu
    UIBarButtonItem * menuBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Menu" style:UIBarButtonItemStyleBordered target:self action:@selector(menuButton:)];
    //set menuBar width for correct position of Menu button in Menu controller
    menuBarButton.width=60.0;

    //add button to navigation bar
    self.navigationItem.leftBarButtonItem=menuBarButton;
    
    //Register a nib file for use in creating new collection view cells.
    [self.collectionView registerNib:[UINib nibWithNibName:@"PESpecialisationCollectionCell" bundle:nil] forCellWithReuseIdentifier:@"SpecialisedCell"];
    
    self.collectionView.delegate= (id)self;
    self.collectionView.dataSource = (id)self;
    
#warning - TO delete
    /*
    //singleton for dataManager
    //PECoreDataManager * dataManager = [PECoreDataManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender{
    PEMenuViewController * menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    //call to menu
    [self.navigationBarLabel removeFromSuperview];
    menuController.textToShow = @"Specialisations";
    menuController.navController = self.navigationController;
    menuController.sizeOfFontInNavLabel = self.navigationBarLabel.font.pointSize;
    menuController.isButtonVisible = true;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height+self.buttonsView.frame.size.height;
    self.navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [self presentViewController:menuController animated:NO completion:nil];
}

- (IBAction)mySpesialisationButton:(id)sender {
}

- (IBAction)moreSpecialisationButton:(id)sender {
}

#pragma mark - CollectionViewDelegate

//on cell clicked
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //create new view and show it
    PEProcedureListViewController * selectedProcedure = [[PEProcedureListViewController alloc] initWithNibName:@"PEProcedureListViewController" bundle:nil];
    [self.navigationController pushViewController:selectedProcedure animated:NO];
}

#pragma mark - CollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 7;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    PESpecialisationCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SpecialisedCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor blueColor];
    
    return cell;
}



@end
