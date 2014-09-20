//
//  Note.h
//  Periop
//
//  Created by Kirill on 9/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Doctors, Procedure;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * textDescription;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Doctors *doctor;
@property (nonatomic, retain) Procedure *procedure;
@property (nonatomic, retain) NSManagedObject *photo;

@end
