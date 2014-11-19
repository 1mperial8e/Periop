//
//  Specialisation.h
//  ScrubUp
//
//  Created by Kirill on 9/24/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Doctors, Procedure;

@interface Specialisation : NSManagedObject

@property (nonatomic, retain) NSString *activeButtonPhotoName;
@property (nonatomic, retain) NSString *inactiveButtonPhotoName;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *photoName;
@property (nonatomic, retain) NSString *specID;
@property (nonatomic, retain) NSString *smallIconName;
@property (nonatomic, retain) NSSet *doctors;
@property (nonatomic, retain) NSSet *procedures;
@end

@interface Specialisation (CoreDataGeneratedAccessors)

- (void)addDoctorsObject:(Doctors *)value;
- (void)removeDoctorsObject:(Doctors *)value;
- (void)addDoctors:(NSSet *)values;
- (void)removeDoctors:(NSSet *)values;

- (void)addProceduresObject:(Procedure *)value;
- (void)removeProceduresObject:(Procedure *)value;
- (void)addProcedures:(NSSet *)values;
- (void)removeProcedures:(NSSet *)values;

@end
