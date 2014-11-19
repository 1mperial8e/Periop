//
//  PEDeletObject.h
//  ScrubUp
//
//  Created by Kirill on 9/11/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEObjectDescription : NSObject

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (copy, nonatomic) NSString *entityName;
@property (copy, nonatomic) NSString *sortDescriptorKey;
@property (copy, nonatomic) NSString *keyPath;
@property (strong, nonatomic) id sortingParameter;

- (id)initWithDeleteObject:(NSManagedObjectContext *)managedObjectContext withEntityName:(NSString *)entityName withSortDescriptorKey:(NSString *)sortDescriptorKey forKeyPath:(NSString *)keyPath withSortingParameter:(id)sortingParameter;

- (id)initWithSearchObject:(NSManagedObjectContext *)managedObjectContext withEntityName:(NSString *)entityName withSortDescriptorKey:(NSString *)sortDescriptorKey;

@end
