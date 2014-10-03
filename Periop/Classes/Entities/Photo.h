//
//  Photo.h
//  Periop
//
//  Created by Kirill on 9/22/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Doctors, EquipmentsTool, Note, OperationRoom, PatientPostioning;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString *photoName;
@property (nonatomic, retain) NSData *photoData;
@property (nonatomic, retain) NSNumber *photoNumber;
@property (nonatomic, retain) Doctors *doctor;
@property (nonatomic, retain) EquipmentsTool *equiomentTool;
@property (nonatomic, retain) Note *note;
@property (nonatomic, retain) OperationRoom *operationRoom;
@property (nonatomic, retain) PatientPostioning *patientPositioning;

@end
