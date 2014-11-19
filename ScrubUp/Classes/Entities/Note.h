//
//  Note.h
//  ScrubUp
//
//  Created by Kirill on 10/23/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Doctors, Photo, Procedure;

@interface Note : NSManagedObject

@property (nonatomic, retain) NSString * textDescription;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) Doctors *doctor;
@property (nonatomic, retain) NSSet *photo;
@property (nonatomic, retain) Procedure *procedure;
@end

@interface Note (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
