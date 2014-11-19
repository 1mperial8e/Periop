//
//  PatientPostioning.h
//  ScrubUp
//
//  Created by Kirill on 9/22/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo, Procedure, Steps;

@interface PatientPostioning : NSManagedObject

@property (nonatomic, retain) NSSet *photo;
@property (nonatomic, retain) Procedure *procedure;
@property (nonatomic, retain) NSSet *steps;
@end

@interface PatientPostioning (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

- (void)addStepsObject:(Steps *)value;
- (void)removeStepsObject:(Steps *)value;
- (void)addSteps:(NSSet *)values;
- (void)removeSteps:(NSSet *)values;

@end
