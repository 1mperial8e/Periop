//
//  EquipmentsTool.h
//  ScrubUp
//
//  Created by Kirill on 9/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class Photo, Procedure;

@interface EquipmentsTool : NSManagedObject

@property (nonatomic, retain) NSString *category;
@property (nonatomic, retain) NSDate *createdDate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *quantity;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, retain) Procedure *procedure;
@property (nonatomic, retain) NSSet *photo;
@end

@interface EquipmentsTool (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
