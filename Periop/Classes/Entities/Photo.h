//
//  Photo.h
//  Periop
//
//  Created by Kirill on 9/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Doctors, EquipmentsTool, Note, OperationRoom, PatientPostioning;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * photoName;
@property (nonatomic, retain) PatientPostioning *patientPositioning;
@property (nonatomic, retain) OperationRoom *operationRoom;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) EquipmentsTool *equiomentTool;
@property (nonatomic, retain) Doctors *doctor;

@end
