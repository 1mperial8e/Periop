//
//  PESpeciaalisationManager.h
//  Periop
//
//  Created by Kirill on 9/18/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Specialisation.h"
#import "Procedure.h"

@interface PESpecialisationManager : NSObject

@property (strong, nonatomic) Specialisation * currentSpecialisation;
@property (strong, nonatomic) Procedure * currentProcedure;

+ (id) sharedManager;

@end
