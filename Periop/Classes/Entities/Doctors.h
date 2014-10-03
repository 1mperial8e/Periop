//
//  Doctors.h
//  Periop
//
//  Created by Kirill on 9/24/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Note, Photo, Procedure, Specialisation;

@interface Doctors : NSManagedObject

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *specialityCode;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSSet *notes;
@property (nonatomic, retain) Photo *photo;
@property (nonatomic, retain) NSSet *procedure;
@property (nonatomic, retain) NSSet *specialisation;
@end

@interface Doctors (CoreDataGeneratedAccessors)

- (void)addNotesObject:(Note *)value;
- (void)removeNotesObject:(Note *)value;
- (void)addNotes:(NSSet *)values;
- (void)removeNotes:(NSSet *)values;

- (void)addProcedureObject:(Procedure *)value;
- (void)removeProcedureObject:(Procedure *)value;
- (void)addProcedure:(NSSet *)values;
- (void)removeProcedure:(NSSet *)values;

- (void)addSpecialisationObject:(Specialisation *)value;
- (void)removeSpecialisationObject:(Specialisation *)value;
- (void)addSpecialisation:(NSSet *)values;
- (void)removeSpecialisation:(NSSet *)values;

@end
