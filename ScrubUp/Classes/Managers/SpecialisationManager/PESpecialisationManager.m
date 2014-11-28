//
//  PESpeciaalisationManager.m
//  ScrubUp
//
//  Created by Kirill on 9/18/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PESpecialisationManager.h"

@implementation PESpecialisationManager

#pragma mark - LifeCycle

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        sharedManager = [[PESpecialisationManager alloc] init];
    });
    return sharedManager;
}

@end
