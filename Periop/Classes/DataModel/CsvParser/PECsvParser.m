//
//  PECsvParser.m
//  Periop
//
//  Created by Kirill on 9/25/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

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

static NSInteger const CPDivideCounter = 5;
static NSString *const CPPlistSpecialisationPicsAndCode = @"SpecialisationPicsAndCode";
static NSString *const CPPlistWithPhotosKey = @"photosPLIST";

@interface PECsvParser ()

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (assign, nonatomic) NSInteger quantityOfProcedures;

@end

@implementation PECsvParser

#pragma mark - LifeCycle

- (id)init
{
    if (self = [super init]) {
        self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    }
    return self;
}

#pragma mark - Public

- (void)parseCsvMainFile:(NSString*)mainFileName csvToolsFile:(NSString*)toolsFileName specName:(NSString *)specName
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
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathMain] && [[NSFileManager defaultManager] fileExistsAtPath:filePathTools]) {
        
        self.quantityOfProcedures = [self getQuantityOfProcedure:filePathMain];
        
        Specialisation *newSpecialisation = [self parseToolsCSVFile:filePathTools specialisationName:specName];
        NSMutableArray *arrayWithProcWithoutTools = [self parseMainCSVFile:filePathMain];
            
        [self mergeAndSaveSpec:arrayWithProcWithoutTools specialisation:newSpecialisation];
    } else {
        NSLog(@"Files not Found!");
    }
}

#pragma mark - Private

- (Specialisation *)parseToolsCSVFile:(NSString*)filePathTools specialisationName:(NSString*)specName
{
    NSEntityDescription *specialisationEntity = [NSEntityDescription entityForName:@"Specialisation" inManagedObjectContext:self.managedObjectContext];
    Specialisation *newSpecialisation = [[Specialisation alloc] initWithEntity:specialisationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
    NSDictionary *pList = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:CPPlistSpecialisationPicsAndCode ofType:@"plist" ]];
    
    NSDictionary *dict = [pList valueForKey:specName];
    newSpecialisation.specID = [dict valueForKey:@"specID"];
    newSpecialisation.photoName = [dict valueForKey:@"photoName"];
    newSpecialisation.activeButtonPhotoName = [dict valueForKey:@"activeButtonPhotoName"];
    newSpecialisation.inactiveButtonPhotoName = [dict valueForKey:@"inactiveButtonPhotoName"];
    newSpecialisation.smallIconName = [dict valueForKey:@"smallIconName"];
    
    newSpecialisation.name = specName;
    
    //tools parsing
    
    NSEntityDescription *procedureEntity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:self.managedObjectContext];
    
    Procedure *newProc = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
    
    NSError *error;
    NSString *lines = [NSString stringWithContentsOfFile:filePathTools encoding:NSUTF8StringEncoding error:&error];
    NSString *partOne = [lines stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    NSString *partTwo = [partOne stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    
    NSDictionary *dicWithPicURL = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:[dict valueForKey:CPPlistWithPhotosKey]]];

    NSArray *rows = [partTwo componentsSeparatedByString:@"\n"];
    for (int i = (int)(rows.count - 1); i >= 0; i--) {
        if ([rows[i] isEqualToString:@""]) {
            continue;
        }
        NSArray *colum = [rows[i] componentsSeparatedByString:@";"];
        
        NSEntityDescription *toolEntity = [NSEntityDescription entityForName:@"EquipmentsTool" inManagedObjectContext:self.managedObjectContext];
        EquipmentsTool *newTool = [[EquipmentsTool alloc] initWithEntity:toolEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        NSString *photoName = (NSString *)colum[6];

        if ([photoName rangeOfString:@"http"].location == NSNotFound && ![photoName isEqualToString:@""]) {
            
            UIImage *photo = [UIImage imageNamedFile:photoName];
            if (photo) {
                
                NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                Photo *initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                
                initPhoto.photoName = colum[6];
                initPhoto.photoData = UIImageJPEGRepresentation(photo, 1.0f);
                initPhoto.equiomentTool = newTool;
                [newTool addPhotoObject:initPhoto];
            } else {
                
                NSString *keyToParse = [NSString stringWithFormat:@"%@.jpg", photoName];
                NSURL *urlForImage = [NSURL URLWithString:[dicWithPicURL valueForKey:keyToParse]];
                NSData *imageDataFromUrl = [NSData dataWithContentsOfURL:urlForImage];
                UIImage *image = [UIImage imageWithData:imageDataFromUrl];
                
                if (image) {
                    NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                    Photo *initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    
                    initPhoto.photoData = UIImageJPEGRepresentation(image, 1.0);
                    initPhoto.equiomentTool = newTool;
                    [newTool addPhotoObject:initPhoto];
                }
                 
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
            if ([[newSpecialisation.procedures allObjects] count] < self.quantityOfProcedures) {
                newProc = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
            }
        }
    }
    return newSpecialisation;
}

- (NSMutableArray*)parseMainCSVFile:(NSString*)filePathMain
{
    NSMutableArray *arrayWithProcWithoutTools = [[NSMutableArray alloc] init];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePathMain]) {
    
        NSEntityDescription *procedureEntity = [NSEntityDescription entityForName:@"Procedure" inManagedObjectContext:self.managedObjectContext];
        
        NSError *error;
        NSString *lines = [NSString stringWithContentsOfFile:filePathMain encoding:NSUTF8StringEncoding error:&error];
        
        NSString *partOne = [lines stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        
        NSArray *parseWithSeparate = [partOne componentsSeparatedByString:@";"];
        NSMutableArray *rows = [parseWithSeparate mutableCopy];
        [rows removeObjectAtIndex:0];
        
        NSEntityDescription *operationEntity = [NSEntityDescription entityForName:@"OperationRoom" inManagedObjectContext:self.managedObjectContext];
        OperationRoom *opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
        NSEntityDescription *patientEntity = [NSEntityDescription entityForName:@"PatientPostioning" inManagedObjectContext:self.managedObjectContext];
        PatientPostioning *pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        Procedure *newProcForDesctiption = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
        
        for (int index = 0 ; index < rows.count; index++) {
            int parseIndex = index % CPDivideCounter;
            switch (parseIndex) {
                case 0:
                    newProcForDesctiption.procedureID = rows[index];
                    break;
                case 1: {
                    NSMutableArray *steps = [[rows[index] componentsSeparatedByString:@"\n"] mutableCopy];
                    if ([[steps lastObject] isEqualToString:@""]) {
                        [steps removeLastObject];
                    }
                    for (int i = 0; i < steps.count; i++) {
                        NSEntityDescription *stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
                        Steps *newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
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
                    for (int i = 0; i < steps.count; i++) {
                        
                        NSString *photoName = (NSString *)steps[i];
                        
                        if ([photoName rangeOfString:@"http"].location == NSNotFound && ![photoName isEqualToString:@""]) {
                            
                            UIImage *photo = [UIImage imageNamedFile:photoName];
                            if (photo) {
                                NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                                Photo *initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
                                initPhoto.photoName = steps[i];
                                initPhoto.photoData = UIImageJPEGRepresentation(photo, 1.0f);
                                [opR addPhotoObject:initPhoto];
                            }
                        } else {
                            NSURL *urlForImage = [NSURL URLWithString:photoName];
                            NSData *imageDataFromUrl = [NSData dataWithContentsOfURL:urlForImage];
                            UIImage *image = [UIImage imageWithData:imageDataFromUrl];
                            
                            if (image) {
                                NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
                                Photo *initPhoto = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
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
                    for (int i = 0; i < steps.count; i++) {
                        NSEntityDescription *preparationEntity = [NSEntityDescription entityForName:@"Preparation" inManagedObjectContext:self.managedObjectContext];
                        Preparation *prep = [[Preparation alloc] initWithEntity:preparationEntity insertIntoManagedObjectContext:self.managedObjectContext];
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
                        NSEntityDescription *stepEntity = [NSEntityDescription entityForName:@"Steps" inManagedObjectContext:self.managedObjectContext];
                        Steps *newStep = [[Steps alloc] initWithEntity:stepEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        newStep.stepName = [NSString stringWithFormat:@"Step %i", i + 1];
                        newStep.stepDescription = steps[i];
                        [pp addStepsObject:newStep];
                    }
                    newProcForDesctiption.operationRoom = opR;
                    newProcForDesctiption.patientPostioning = pp;
                    
                    [arrayWithProcWithoutTools addObject:newProcForDesctiption];
                    
                    if (arrayWithProcWithoutTools.count < self.quantityOfProcedures) {
                        opR = [[OperationRoom alloc] initWithEntity:operationEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        pp = [[PatientPostioning alloc] initWithEntity:patientEntity insertIntoManagedObjectContext:self.managedObjectContext];
                        newProcForDesctiption = [[Procedure alloc] initWithEntity:procedureEntity insertIntoManagedObjectContext:self.managedObjectContext];
                    }
                    
                }
                    break;
            }
        }
    }
    return arrayWithProcWithoutTools;
}

- (void)mergeAndSaveSpec:(NSMutableArray*)arrayWithProcWithoutTools specialisation:(Specialisation*)newSpecialisation
{
    if (arrayWithProcWithoutTools.count && [newSpecialisation.procedures allObjects].count) {
        for (Procedure *procToMerge in [newSpecialisation.procedures allObjects]) {
            for (int i = 0; i < arrayWithProcWithoutTools.count; i++) {
                if ([procToMerge.procedureID isEqualToString:((Procedure *)arrayWithProcWithoutTools[i]).procedureID]){
                    procToMerge.patientPostioning = ((Procedure *)arrayWithProcWithoutTools[i]).patientPostioning;
                    procToMerge.operationRoom = ((Procedure *)arrayWithProcWithoutTools[i]).operationRoom;
                    [procToMerge addPreparation:((Procedure *)arrayWithProcWithoutTools[i]).preparation];
                    [self.managedObjectContext deleteObject:((Procedure *)arrayWithProcWithoutTools[i])];
                }
            }
        }
        
    } else {
        NSLog (@"No input data");
    }

    NSError *saveError;
    if ([self.managedObjectContext save:&saveError]) {
        NSLog(@"Parsing data from CSV succcess");
        [self.managedObjectContext reset];
    } else {
        NSLog(@"Fail to parse data from CSV - %@", saveError.localizedDescription);
    }
}

- (NSInteger)getQuantityOfProcedure:(NSString *)filePathMain
{
    NSError *error;
    NSString *lines = [NSString stringWithContentsOfFile:filePathMain encoding:NSUTF8StringEncoding error:&error];
    
    NSString *partOne = [lines stringByReplacingOccurrencesOfString:@"\"" withString:@""];
    
    NSArray *parseWithSeparate = [partOne componentsSeparatedByString:@";"];
    NSMutableArray *rows = [parseWithSeparate mutableCopy];
    [rows removeObjectAtIndex:0];
    return (rows.count / CPDivideCounter);
}

@end