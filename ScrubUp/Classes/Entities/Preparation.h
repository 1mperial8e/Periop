//
//  Preparation.h
//  ScrubUp
//
//  Created by Kirill on 9/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Procedure;

@interface Preparation : NSManagedObject

@property (nonatomic, retain) NSString *preparationText;
@property (nonatomic, retain) NSString *stepName;
@property (nonatomic, retain) Procedure *procedure;

@end
