//
//  PECoreDataManager.h
//  Periop
//
//  Created by Kirill on 9/10/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PEObjectDescription.h"

@interface PECoreDataManager : NSObject

//space for core data all objects
@property (readonly, strong, nonatomic) NSManagedObjectContext * managedObjectContext;
//collection of entities
@property (readonly, strong, nonatomic) NSManagedObjectModel * managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator * persistentStoreCoordinator;

//singleton method
+ (id)sharedManager;

//remove object
+ (void)removeFromDB:(PEObjectDescription *)deleteObjectDescription withManagedObject:(NSManagedObject*)managedObject;
//search for all entities objects
+ (NSArray *)getAllEntities: (PEObjectDescription*)getObjectDescription;

@end



