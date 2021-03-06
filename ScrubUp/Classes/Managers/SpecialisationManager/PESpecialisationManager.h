//
//  PESpeciaalisationManager.h
//  ScrubUp
//
//  Created by Kirill on 9/18/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "Specialisation.h"
#import "Procedure.h"
#import "EquipmentsTool.h"
#import "OperationRoom.h"
#import "Doctors.h"
#import "Photo.h"

@interface PESpecialisationManager : NSObject

@property (strong, nonatomic) Specialisation *currentSpecialisation;
@property (strong, nonatomic) Procedure *currentProcedure;
@property (strong, nonatomic) EquipmentsTool *currentEquipment;
@property (strong, nonatomic) Note *currentNote;
@property (strong, nonatomic) Doctors *currentDoctor;
@property (strong, nonatomic) Steps *currentStep;
@property (strong, nonatomic) Preparation *currentPreparation;

@property (assign, nonatomic) BOOL isProcedureSelected;
@property (strong, nonatomic) Photo *photoObject;
@property (strong, nonatomic) NSMutableArray *photoObjectsToSave;

@property (strong, nonatomic) NSMutableSet *cellWithCheckedButtons;
@property (strong, nonatomic) NSMutableSet *indexPathForCheckedButtons;

@property (assign, nonatomic) BOOL isDownloadingEnded;

+ (id)sharedManager;

@end
