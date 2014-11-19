//
//  Procedure.h
//  ScrubUp
//
//  Created by Kirill on 9/22/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Doctors, EquipmentsTool, Note, OperationRoom, PatientPostioning, Preparation, Specialisation;

@interface Procedure : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *procedureID;
@property (nonatomic, retain) NSSet *doctors;
@property (nonatomic, retain) NSSet *equipments;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) OperationRoom *operationRoom;
@property (nonatomic, retain) PatientPostioning *patientPostioning;
@property (nonatomic, retain) NSSet *preparation;
@property (nonatomic, retain) Specialisation *specialization;
@end

@interface Procedure (CoreDataGeneratedAccessors)

- (void)addDoctorsObject:(Doctors *)value;
- (void)removeDoctorsObject:(Doctors *)value;
- (void)addDoctors:(NSSet *)values;
- (void)removeDoctors:(NSSet *)values;

- (void)addEquipmentsObject:(EquipmentsTool *)value;
- (void)removeEquipmentsObject:(EquipmentsTool *)value;
- (void)addEquipments:(NSSet *)values;
- (void)removeEquipments:(NSSet *)values;

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addPreparationObject:(Preparation *)value;
- (void)removePreparationObject:(Preparation *)value;
- (void)addPreparation:(NSSet *)values;
- (void)removePreparation:(NSSet *)values;

@end
