//
//  Preparation.h
//  Periop
//
//  Created by Kirill on 9/18/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Procedure;

@interface Preparation : NSManagedObject

@property (nonatomic, retain) NSString * preparationText;
@property (nonatomic, retain) Procedure *procedure;

@end
