//
//  PECoreDataManager.m
//  Periop
//
//  Created by Kirill on 9/10/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PECoreDataManager.h"
#import <CoreData/CoreData.h>

@implementation PECoreDataManager

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

#pragma mark - Singleton

+ (id) sharedManager{
    static id coreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataManager = [[self alloc] init];
    });
    return coreDataManager;
}

- (id)init{
    if (self= [super init]){
        
    }
    return self;
}

#pragma mark - CoreData

//collection of model objects
- (NSManagedObjectContext*) managedObjectContext{
    
    if (_managedObjectContext!=nil){
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator * coordinator = [self persistentStoreCoordinator];
    if (coordinator!=nil){
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

//shcema of DB
- (NSManagedObjectModel * ) managedObjectModel {
    if (_managedObjectModel !=nil){
        return _managedObjectModel;
    }
    //url for storing model
    NSURL * modelURL = [[NSBundle mainBundle] URLForResource:@"PeriopDataBase" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

//constructor; store and manage data
- (NSPersistentStoreCoordinator*) persistentStoreCoordinator{
    if (_persistentStoreCoordinator!=nil){
        return _persistentStoreCoordinator;
    }
    //place for storing DB
    NSURL* storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PeriopDataBase.sqlite"];
    NSError* error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        [self backupDBIfError:storeURL];
        NSLog(@"Problem with creating persostent store coordinator");
    }
    return _persistentStoreCoordinator;
}


#pragma mark - Application Documents Directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)nameForIncompatibleStore {
    // Initialize Date Formatter
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    // Configure Date Formatter
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    return [NSString stringWithFormat:@"%@.sqlite", [dateFormatter stringFromDate:[NSDate date]]];
}

#pragma mark - Data Backup

- (void)backupDBIfError: (NSURL*)urlOfDB{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[urlOfDB path]]){
        //create path for saving corrupted data
        NSURL* corruptedURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self nameForIncompatibleStore]];
        NSError* error = nil;
        //move DB to new location
        [fileManager moveItemAtURL:urlOfDB toURL:corruptedURL error:&error];
        
        //show alert to user
        NSString * title= @"Warning";
        NSString * applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString* message = [NSString stringWithFormat:@"A serious application error occurred while %@ tried to read your data. Please contact support for help.", applicationName];
        UIAlertView * alerView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
    }
}

#pragma mark - Data Managment

+ (void)removeFromDB: (PEObjectDescription *)deleteObjectDescription withManagedObject:(NSManagedObject *)managedObject{
    
    //create Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:deleteObjectDescription.entityName];
    //create sort Descriptor
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:deleteObjectDescription.sortDescriptorKey ascending:YES];
    //fetching
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError * error = nil;
    //get result
    NSArray * result = [deleteObjectDescription.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    //find and delete
    for (managedObject in result){
        if ([[managedObject valueForKeyPath:deleteObjectDescription.keyPath] isEqual:deleteObjectDescription.sortingParameter]){
            [managedObject.managedObjectContext deleteObject:managedObject];
            NSError * err = nil;
            if (![managedObject.managedObjectContext save:&err]){
                NSLog(@"Error during deleting - %@", err.localizedDescription);
            }
        }
    }
}

+ (NSArray *)getAllEntities: (PEObjectDescription*)getObjectDescription{
    //create Fetch Request
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:getObjectDescription.entityName];
    //create sort Descriptor
    NSSortDescriptor * sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:getObjectDescription.sortDescriptorKey ascending:YES];
    //fetching
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError * error = nil;
    //get result
    NSArray * result = [getObjectDescription.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return result;
}

@end
