//
//  PEDeletObject.m
//  Periop
//
//  Created by Kirill on 9/11/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEObjectDescription.h"

@implementation PEObjectDescription

- (id)initWithDeleteObject:(NSManagedObjectContext *)managedObjectContext withEntityName:(NSString *)entityName withSortDescriptorKey:(NSString *)sortDescriptorKey forKeyPath:(NSString *)keyPath withSortingParameter:(id)sortingParameter
{
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        _entityName = entityName;
        _sortDescriptorKey = sortDescriptorKey;
        _keyPath = keyPath;
        _sortingParameter = sortingParameter;
    }
    return self;
}

- (id)initWithSearchObject:(NSManagedObjectContext *)managedObjectContext withEntityName:(NSString *)entityName withSortDescriptorKey:(NSString *)sortDescriptorKey
{
    if (self = [super init]) {
        _managedObjectContext = managedObjectContext;
        _entityName = entityName;
        _sortDescriptorKey = sortDescriptorKey;
        _keyPath = nil;
        _sortingParameter = nil;
    }
    return self;
}

@end
