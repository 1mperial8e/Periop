//
//  PEPlistParser.m
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEPlistParser.h"
#import "PECoreDataManager.h"
#import "EquipmentsTool.h"
#import "Procedure.h"
#import "OperationRoom.h"
#import "Doctors.h"
#import "PatientPostioning.h"
#import "Note.h"
#import "Preparation.h"
#import "Photo.h"
#import "Steps.h"

@interface PEPlistParser()

@property (strong, nonatomic) NSMutableArray* patientPostioning;
@property (strong, nonatomic) NSMutableArray* preparation;
@property (strong, nonatomic) NSMutableArray * operationRoom;
@property (strong, nonatomic) NSDictionary * tools;
@property (strong, nonatomic) NSArray* pList;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@end

@implementation PEPlistParser

- (id)init
{
    if (self =[super init]) {
        self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    }
    return self;
}

- (void)parsePList:(NSString*)pListName specialisation:(SpecialisationParser)handler
{
    self.pList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:pListName ofType:@"plist" ]];
    
    NSEntityDescription * specialisationEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    Specialisation * newSpecialisation = [[Specialisation alloc] initWithEntity:specialisationEntity insertIntoManagedObjectContext:self.managedObjectContext];
    
    if ([pListName isEqualToString:@"ENT - Ear, Nose & Throat"]){
        newSpecialisation.specID = @"S01";
        newSpecialisation.photoName = @"ENT_Large";
        newSpecialisation.activeButtonPhotoName = @"ENT_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"ENT_Small_Inactive";
    } else if ([pListName isEqualToString:@"Gyneacology"]){
        newSpecialisation.specID = @"S02";
        newSpecialisation.photoName = @"Gyneacology_Large";
        newSpecialisation.activeButtonPhotoName = @"Gyneacology_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Gyneacology_Small_Inactive";
    } else if ([pListName isEqualToString:@"Obstetric"]){
        newSpecialisation.specID = @"S03";
        newSpecialisation.photoName = @"Obstetric_Large";
        newSpecialisation.activeButtonPhotoName = @"Obstetric_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Obstetric_Small_Inactive";
    } else if ([pListName isEqualToString:@"Opthalmology"]){
        newSpecialisation.specID = @"S04";
        newSpecialisation.photoName = @"Opthalmology";
        newSpecialisation.activeButtonPhotoName = @"Opthalmology_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Opthalmology_Small_Inactive";
    } else if ([pListName isEqualToString:@"Cardiothoracic"]){
        newSpecialisation.photoName = @"Cardiothoracic_Large";
        newSpecialisation.specID = @"S05";
        newSpecialisation.activeButtonPhotoName = @"Cardiothoracic_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Cardiothoracic_Small_Inactive";
    } else if ([pListName isEqualToString:@"Orthopeadic"]){
        newSpecialisation.specID = @"S06";
        newSpecialisation.photoName = @"Orthopeadic_Large";
        newSpecialisation.activeButtonPhotoName = @"Orthopeadic_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Orthopeadic_Small_Inactive";
    } else if ([pListName isEqualToString:@"Plastic"]){
        newSpecialisation.specID = @"S07";
        newSpecialisation.photoName = @"Plastic_Large";
        newSpecialisation.activeButtonPhotoName = @"Plastic_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Plastic_Small_Inactive";
    } else if ([pListName isEqualToString:@"Cosmetic"]){
        newSpecialisation.specID = @"S08";
        newSpecialisation.photoName = @"Cosmetic_Large";
        newSpecialisation.activeButtonPhotoName = @"Cosmetic_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Cosmetic_Small_Inactive";
    } else if ([pListName isEqualToString:@"General"]){
        newSpecialisation.specID = @"S09";
        newSpecialisation.photoName = @"General_Large";
        newSpecialisation.activeButtonPhotoName = @"General_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"General_Small_Inactive";
    } else if ([pListName isEqualToString:@"Colorectal"]){
        newSpecialisation.specID = @"S10";
        newSpecialisation.photoName = @"Colorectal_Large";
        newSpecialisation.activeButtonPhotoName = @"Colorectal_Small_Active";
        newSpecialisation.inactiveButtonPhotoName =@"Colorectal_Small_Inactive";
    }

    newSpecialisation.name = pListName;
    
    for (NSDictionary * dicWithProcedure in self.pList) {
        NSEntityDescription * procedureEntity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:self.managedObjectContext];
        Procedure * currentProcedure = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        currentProcedure.procedureID = [dicWithProcedure valueForKey:@"ProcedureID"];
        currentProcedure.name = [dicWithProcedure valueForKey:@"Procedure/Operation Title"];
        currentProcedure.specialization = newSpecialisation;
        
        NSEntityDescription * patientEntity = [NSEntityDescription entityForName:@"PatientPostioning" inManagedObjectContext:self.managedObjectContext];
        PatientPostioning * pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        NSArray * patientPostionning = (NSArray*)[dicWithProcedure valueForKey:@"Patient Positioning"];
        [patientPostionning enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSEntityDescription * stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
            Steps * newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
            newStep.stepName = [NSString stringWithFormat:@"Step %i", idx + 1];
            newStep.stepDescription = (NSString *)obj;
            [pp addStepsObject:newStep];
        }];
        pp.procedure = currentProcedure;
        currentProcedure.patientPostioning = pp;
        
        NSArray *preparation = (NSArray *)[dicWithProcedure valueForKey:@"Preparation"];
        [preparation enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSEntityDescription * preparationEntity = [NSEntityDescription entityForName:@"Preparation" inManagedObjectContext:self.managedObjectContext];
            Preparation * prep = [[Preparation alloc] initWithEntity:preparationEntity insertIntoManagedObjectContext:self.managedObjectContext];
            prep.stepName = [NSString stringWithFormat:@"Step %i", idx + 1];
            prep.preparationText = (NSString*)obj;
            prep.procedure = currentProcedure;
            [currentProcedure addPreparationObject:prep];
        }];
        
        NSEntityDescription * operationEntity = [NSEntityDescription entityForName:@"OperationRoom" inManagedObjectContext:self.managedObjectContext];
        OperationRoom * opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        NSArray *operationRoomArray = (NSArray *)[dicWithProcedure valueForKey:@"Operation Room"];
        [operationRoomArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSEntityDescription * stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
            Steps * newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
            newStep.stepName = [NSString stringWithFormat:@"Step %i", idx + 1];
            newStep.stepDescription = (NSString *)obj;
            [opR addStepsObject:newStep];
        }];
        opR.procedure = currentProcedure;
        currentProcedure.operationRoom = opR;
        
        NSDictionary * dicWithTools = [dicWithProcedure valueForKey:@"Tools"];
        
        NSArray* keys = [dicWithTools allKeys];
        for (int i=0; i< keys.count; i++) {

            for (NSDictionary *category in [dicWithTools valueForKey:keys[i]]){
                NSEntityDescription * toolEntity = [NSEntityDescription entityForName:@"EquipmentsTool" inManagedObjectContext:self.managedObjectContext];
                EquipmentsTool * newTool = [[EquipmentsTool alloc] initWithEntity:toolEntity insertIntoManagedObjectContext:self.managedObjectContext];
                
                newTool.createdDate = [NSDate date];
                newTool.category = keys[i];
                newTool.quantity = [category valueForKey:@"Tool Quantity"];
                newTool.name = [category valueForKey:@"Tool Name"];
                newTool.type = [category valueForKey:@"Tool Spec"];
                
                NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                Photo * initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                initPhoto.photoName = [category valueForKey:@"Tool Photo ID"];
                [newTool addPhotoObject:initPhoto];
                newTool.procedure = currentProcedure;
                [currentProcedure addEquipmentsObject:newTool];
            }
        }

        [newSpecialisation addProceduresObject:currentProcedure];
    }
    
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Fail to parse data from PList - %@", saveError.localizedDescription);
    } else {
        NSLog(@"Parsing data from PLIST succcess");
    }
    handler(newSpecialisation);
}

@end
