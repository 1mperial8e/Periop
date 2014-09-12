//
//  PEDeletObject.h
//  Periop
//
//  Created by Kirill on 9/11/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PEObjectDescription : NSObject

//Managed ObjectContext
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
//name of entity that must be deleted - used in fetchRequest and NSEntityDesccription objects
@property (copy, nonatomic) NSString* entityName;
//sortDescriptor key - key for getting values of table
@property (copy, nonatomic) NSString* sortDescriptorKey;
//name of attribute - wiil be used for comparing value of this attribute with sortingParameter
@property (copy, nonatomic) NSString* keyPath;
//parameter for comparing and finding required entity 
@property (strong, nonatomic) id sortingParameter;

- (id) initWithDeleteObject :(NSManagedObjectContext*)managedObjectContext withEntityName:(NSString*)entityName withSortDescriptorKey:(NSString*)sortDescriptorKey forKeyPath:(NSString*)keyPath withSortingParameter:(id)sortingParameter;

- (id) initWithSearchObject :(NSManagedObjectContext*)managedObjectContext withEntityName:(NSString*)entityName withSortDescriptorKey:(NSString*)sortDescriptorKey;

@end
