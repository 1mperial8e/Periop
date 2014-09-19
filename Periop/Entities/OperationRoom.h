//
//  OperationRoom.h
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Procedure;

@interface OperationRoom : NSManagedObject

@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) NSString * stepDescription;
@property (nonatomic, retain) NSString * stepName;
@property (nonatomic, retain) Procedure *procedure;

@end
