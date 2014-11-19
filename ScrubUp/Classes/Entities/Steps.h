//
//  Steps.h
//  ScrubUp
//
//  Created by Kirill on 9/22/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <CoreData/CoreData.h>

@class OperationRoom, PatientPostioning;

@interface Steps : NSManagedObject

@property (nonatomic, retain) NSString *stepDescription;
@property (nonatomic, retain) NSString *stepName;
@property (nonatomic, retain) OperationRoom *operationRoom;
@property (nonatomic, retain) PatientPostioning *patientPostioning;

@end
