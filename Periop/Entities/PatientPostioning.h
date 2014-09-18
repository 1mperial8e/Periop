//
//  PatientPostioning.h
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Procedure;

@interface PatientPostioning : NSManagedObject

@property (nonatomic, retain) NSString * patientDescription;
@property (nonatomic, retain) NSString * photo;
@property (nonatomic, retain) Procedure *procedure;

@end
