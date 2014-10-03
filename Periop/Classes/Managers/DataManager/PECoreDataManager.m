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

+ (id)sharedManager
{
    static id coreDataManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreDataManager = [[self alloc] init];
    });
    return coreDataManager;
}

#pragma mark - CoreData

- (NSManagedObjectContext*) managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"PeriopDataBase" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"PeriopDataBase.sqlite"];
    NSError *error;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.managedObjectModel];
    
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]){
        [self backupDBIfError:storeURL];
        NSLog(@"Problem with creating persostent store coordinator");
    }
    return _persistentStoreCoordinator;
}


#pragma mark - Application Documents Directory

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSString *)nameForIncompatibleStore
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH-mm-ss"];
    
    return [NSString stringWithFormat:@"%@.sqlite", [dateFormatter stringFromDate:[NSDate date]]];
}

#pragma mark - Data Backup

- (void)backupDBIfError:(NSURL *)urlOfDB
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:[urlOfDB path]]) {
        NSURL *corruptedURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[self nameForIncompatibleStore]];
        NSError *error;
        [fileManager moveItemAtURL:urlOfDB toURL:corruptedURL error:&error];
        
        NSString *title= @"Warning";
        NSString *applicationName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *message = [NSString stringWithFormat:@"A serious application error occurred while %@ tried to read your data. Please contact support for help.", applicationName];
        UIAlertView *alerView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alerView show];
    }
}

#pragma mark - Data Managment

+ (void)removeFromDB:(PEObjectDescription *)deleteObjectDescription withManagedObject:(NSManagedObject *)managedObject
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:deleteObjectDescription.entityName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:deleteObjectDescription.sortDescriptorKey ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error;
    NSArray *result = [deleteObjectDescription.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    
    for (managedObject in result){
        if ([[managedObject valueForKeyPath:deleteObjectDescription.keyPath] isEqual:deleteObjectDescription.sortingParameter]) {
            [managedObject.managedObjectContext deleteObject:managedObject];
            NSError *err;
            if (![managedObject.managedObjectContext save:&err]){
                NSLog(@"Error during deleting - %@", err.localizedDescription);
            }
        }
    }
}

+ (NSArray *)getAllEntities:(PEObjectDescription *)getObjectDescription
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:getObjectDescription.entityName];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:getObjectDescription.sortDescriptorKey ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    NSArray *result = [getObjectDescription.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    return result;
}

@end
