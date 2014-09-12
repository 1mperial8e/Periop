//
//  Entity.h
//  Periop
//
//  Created by Kirill on 9/11/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity, SomeEntity;

@interface Entity : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *someEntity;
@property (nonatomic, retain) NSSet *thisEntity;
@end

@interface Entity (CoreDataGeneratedAccessors)

- (void)addSomeEntityObject:(SomeEntity *)value;
- (void)removeSomeEntityObject:(SomeEntity *)value;
- (void)addSomeEntity:(NSSet *)values;
- (void)removeSomeEntity:(NSSet *)values;

- (void)addThisEntityObject:(Entity *)value;
- (void)removeThisEntityObject:(Entity *)value;
- (void)addThisEntity:(NSSet *)values;
- (void)removeThisEntity:(NSSet *)values;

@end
