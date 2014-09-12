//
//  SomeEntity.h
//  Periop
//
//  Created by Kirill on 9/11/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Entity;

@interface SomeEntity : NSManagedObject

@property (nonatomic, retain) NSString * attribute;
@property (nonatomic, retain) NSString * attribute1;
@property (nonatomic, retain) NSString * attribute2;
@property (nonatomic, retain) Entity *toEntity;

@end
