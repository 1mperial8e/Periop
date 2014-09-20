//
//  OperationRoom.h
//  Periop
//
//  Created by Kirill on 9/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo, Procedure;

@interface OperationRoom : NSManagedObject

@property (nonatomic, retain) NSString * stepDescription;
@property (nonatomic, retain) NSString * stepName;
@property (nonatomic, retain) Procedure *procedure;
@property (nonatomic, retain) NSSet *photo;
@end

@interface OperationRoom (CoreDataGeneratedAccessors)

- (void)addPhotoObject:(Photo *)value;
- (void)removePhotoObject:(Photo *)value;
- (void)addPhoto:(NSSet *)values;
- (void)removePhoto:(NSSet *)values;

@end
