//
//  EquipmentsTool.h
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Procedure;

@interface EquipmentsTool : NSManagedObject

@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSDate * createdDate;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * quantity;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Procedure *procedure;

@end
