//
//  PECoreDataManager.h
//  Periop
//
//  Created by Kirill on 9/10/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEObjectDescription.h"

@interface PECoreDataManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (id)sharedManager;

+ (void)removeFromDB:(PEObjectDescription *)deleteObjectDescription withManagedObject:(NSManagedObject *)managedObject;
+ (NSArray *)getAllEntities:(PEObjectDescription *)getObjectDescription;

@end



