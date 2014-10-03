//
//  PECsvParser.m
//  Periop
//
//  Created by Kirill on 9/25/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSInteger const CPProcedureCount = 20;

#import "PECsvParser.h"
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
#import "Specialisation.h"
#import "UIImage+ImageWithJPGFile.h"

@interface PECsvParser ()

@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) NSFetchedResultsController * fetchedResultController;

@end

@implementation PECsvParser

#pragma mark - LifeCycle

- (id)init
{
    if (self =[super init]) {
        self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    }
    return self;
}

#pragma mark - Public

- (void)parseCsv:(NSString*)mainFileName withCsvToolsFileName:(NSString*)toolsFileName withSpecName:(NSString *)specName
{
    NSString *filePathMain = [[NSBundle mainBundle] pathForResource:mainFileName ofType:@"csv"];
    NSString *filePathTools = [[NSBundle mainBundle] pathForResource:toolsFileName ofType:@"csv"];
    
    if (!filePathMain) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        filePathMain = [NSString stringWithFormat:@"%@/%@.csv" , paths[0], mainFileName];
    }
    if (!filePathTools) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        filePathTools = [NSString stringWithFormat:@"%@/%@.csv" , paths[0], toolsFileName];
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:filePathMain]==YES && [fileManager fileExistsAtPath:filePathTools]==YES) {
        
        NSEntityDescription * specialisationEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
        Specialisation * newSpecialisation = [[Specialisation alloc] initWithEntity:specialisationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SpecialisationPicsAndCode" ofType:@"plist" ]];
        
        NSDictionary * dic = [pList valueForKey:specName];
        newSpecialisation.specID = [dic valueForKey:@"specID"];
        newSpecialisation.photoName = [dic valueForKey:@"photoName"];
        newSpecialisation.activeButtonPhotoName = [dic valueForKey:@"activeButtonPhotoName"];
        newSpecialisation.inactiveButtonPhotoName =[dic valueForKey:@"inactiveButtonPhotoName"];
        newSpecialisation.smallIconName = [dic valueForKey:@"smallIconName"];
        
        newSpecialisation.name = specName;
        
        //tools parsing
        
        NSEntityDescription * procedureEntity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:self.managedObjectContext];

        
        if ([fileManager fileExistsAtPath:filePathTools]==YES) {
            Procedure * newProc = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
            
            NSError *error;
            NSString *lines = [NSString stringWithContentsOfFile:filePathTools encoding:NSUTF8StringEncoding error:&error];
            //     NSLog(@"%@",lines);
            
            NSString *partOne = [lines stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            NSString *partTwo = [partOne stringByReplacingOccurrencesOfString:@"\r" withString:@""];
            //     NSLog(@"%@",partTwo);
            
            NSArray *rows = [partTwo componentsSeparatedByString:@"\n"];
            for (int i = rows.count - 1; i >= 0; i--) {
                if ([rows[i] isEqualToString:@""]) {
                    continue;
                }
                NSArray *colum = [rows[i] componentsSeparatedByString:@";"];
                
                NSEntityDescription * toolEntity = [NSEntityDescription entityForName:@"EquipmentsTool" inManagedObjectContext:self.managedObjectContext];
                EquipmentsTool * newTool = [[EquipmentsTool alloc] initWithEntity:toolEntity insertIntoManagedObjectContext:self.managedObjectContext];
                
                NSString *photoName = (NSString *)colum[6];
                
                if ([photoName rangeOfString:@"http"].location == NSNotFound && ![photoName isEqualToString:@""]) {
            
                    UIImage * photo = [UIImage imageNamedFile:photoName];
                    if (photo) {
                        
                        NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                        Photo * initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        
                        initPhoto.photoName = colum[6];
                        initPhoto.equiomentTool = newTool;
                        [newTool addPhotoObject:initPhoto];
                    }
                } else {
                    // to download photo and check; if yes save in initPhoto.photoData
                    NSURL * urlForImage = [NSURL URLWithString:photoName];
                    NSData * imageDataFromUrl = [NSData dataWithContentsOfURL:urlForImage];
                    UIImage * image = [UIImage imageWithData:imageDataFromUrl];
                    
                    if (image) {
                        NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                        Photo * initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        
                        initPhoto.photoData = UIImageJPEGRepresentation(image, 1.0);
                        initPhoto.equiomentTool = newTool;
                        [newTool addPhotoObject:initPhoto];
                    }
                }
                
                newTool.quantity = colum[5];
                newTool.type = colum[4];
                newTool.name = colum[3];
                newTool.category = colum[2];
                newTool.createdDate = [NSDate date];
                [newProc addEquipmentsObject:newTool];
                
                if (![colum[0] isEqualToString:@""]) {
                    newProc.procedureID = colum[0];
                    newProc.name = colum[1];
                    [newSpecialisation addProceduresObject:newProc];
                    if ([[newSpecialisation.procedures allObjects] count] < CPProcedureCount) {
                        newProc = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    }
                }
            }
        } else {
            NSLog (@"File with tools not found");
        }
        
        //parse mainFile
        NSError *error;
        NSString *lines = [NSString stringWithContentsOfFile:filePathMain encoding:NSUTF8StringEncoding error:&error];
        //  NSLog(@"%@",lines);
        
        NSString *partOne = [lines stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *parseWithSeparate = [partOne componentsSeparatedByString:@";"];
        NSMutableArray *rows = [parseWithSeparate mutableCopy];
        [rows removeObjectAtIndex:0];
        
        NSEntityDescription * operationEntity = [NSEntityDescription entityForName:@"OperationRoom" inManagedObjectContext:self.managedObjectContext];
        OperationRoom * opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSEntityDescription * patientEntity = [NSEntityDescription entityForName:@"PatientPostioning" inManagedObjectContext:self.managedObjectContext];
        PatientPostioning * pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        //create procedure temporary
        Procedure * newProcForDesctiption = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        NSMutableArray * arrayWithProcWithTools = [[NSMutableArray alloc] init];

        for (int index = 0 ; index < rows.count; index++) {
            int parseIndex = index%5;
            switch (parseIndex) {
                case 0:
                    newProcForDesctiption.procedureID = rows[index];
                    break;
                case 1: {
                    NSMutableArray *steps = [[rows[index] componentsSeparatedByString:@"\n"] mutableCopy];
                    if ([[steps lastObject] isEqualToString:@""]) {
                        [steps removeLastObject];
                    }
                    for (int i=0; i<steps.count; i++) {
                        NSEntityDescription * stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
                        Steps * newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        newStep.stepName = [NSString stringWithFormat:@"Step %i", i + 1];
                        newStep.stepDescription = steps[i];
                        [opR addStepsObject:newStep];
                    }
                }
                    break;
                case 2: {
                    NSMutableArray *steps = [[rows[index] componentsSeparatedByString:@","] mutableCopy];
                    if ([[steps lastObject] isEqualToString:@""]) {
                        [steps removeLastObject];
                    }
                    for (int i=0; i<steps.count; i++) {
                        
                        NSString *photoName = (NSString *)steps[i];
                        
                        if ([photoName rangeOfString:@"http"].location == NSNotFound && ![photoName isEqualToString:@""]) {
                            
                            UIImage * photo = [UIImage imageNamedFile:photoName];
                            if (photo) {
                                NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                                Photo * initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                                initPhoto.photoName = steps[i];
                                [opR addPhotoObject:initPhoto];
                            }
                        } else {
                        // to download photo and check; if yes save in initPhoto.photoData
                            NSURL * urlForImage = [NSURL URLWithString:photoName];
                            NSData * imageDataFromUrl = [NSData dataWithContentsOfURL:urlForImage];
                            UIImage * image = [UIImage imageWithData:imageDataFromUrl];
                            
                            if (image) {
                                NSEntityDescription * photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                                Photo * initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                                initPhoto.photoData = UIImageJPEGRepresentation(image, 1.0);
                                [opR addPhotoObject:initPhoto];
                            }
                        }
                    }
                }
                    break;
                case 3: {
                    NSMutableArray *steps = [[rows[index] componentsSeparatedByString:@"\n"] mutableCopy];
                    if ([[steps lastObject] isEqualToString:@""]) {
                        [steps removeLastObject];
                    }
                    for (int i=0; i<steps.count; i++) {
                        NSEntityDescription * preparationEntity = [NSEntityDescription entityForName:@"Preparation" inManagedObjectContext:self.managedObjectContext];
                        Preparation * prep = [[Preparation alloc] initWithEntity:preparationEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        prep.stepName = [NSString stringWithFormat:@"Step %i", i + 1];
                        prep.preparationText = steps[i];
                        prep.procedure = newProcForDesctiption;
                        [newProcForDesctiption addPreparationObject:prep];
                    }
                }
                    break;
                case 4: {
                    NSMutableArray *steps = [[rows[index] componentsSeparatedByString:@"\n"] mutableCopy];
                    if (((NSString *)[steps lastObject]).length == 1 || [[steps lastObject] isEqualToString:@""]) {
                        [steps removeLastObject];
                    }
                    for (int i=0; i<steps.count; i++) {
                        NSEntityDescription * stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
                        Steps * newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        newStep.stepName = [NSString stringWithFormat:@"Step %i", i + 1];
                        newStep.stepDescription = steps[i];
                        [pp addStepsObject:newStep];
                    }
                    
                    newProcForDesctiption.operationRoom = opR;
                    newProcForDesctiption.patientPostioning = pp;
                    
                    [arrayWithProcWithTools addObject:newProcForDesctiption];
                    if (arrayWithProcWithTools.count < CPProcedureCount) {
                        opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        newProcForDesctiption = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    }
                }
                    break;
            }
        }
        
        //here marge procs
        
        for (Procedure* procToMerge in [newSpecialisation.procedures allObjects]) {
            for (int i =0; i< arrayWithProcWithTools.count; i++) {
                if ([procToMerge.procedureID isEqualToString:((Procedure*)arrayWithProcWithTools[i]).procedureID]){
                    procToMerge.patientPostioning = ((Procedure*)arrayWithProcWithTools[i]).patientPostioning;
                    procToMerge.operationRoom = ((Procedure*)arrayWithProcWithTools[i]).operationRoom;
                    [procToMerge addPreparation:((Procedure*)arrayWithProcWithTools[i]).preparation];
                    [self.managedObjectContext deleteObject:((Procedure*)arrayWithProcWithTools[i])];
                }
            }
        }
        
    } else NSLog (@"File with description of specialisation's procedures NOT found");
    
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]) {
        NSLog(@"Fail to parse data from CSV - %@", saveError.localizedDescription);
    } else {
        NSLog(@"Parsing data from CSV succcess");
    }
}



@end