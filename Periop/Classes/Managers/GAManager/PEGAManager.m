//
//  PEGAManager.m
//  Periop
//
//  Created by Stas Volskyi on 30.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEGAManager.h"
#import "GAIDictionaryBuilder.h"

static NSString *const GATrackingID = @"UA-56255562-1";
static NSString *const GAMDoctorCreated = @"doctorCreated";

@implementation PEGAManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[GAI sharedInstance] trackerWithTrackingId:GATrackingID];
        self.tracker = [[GAI sharedInstance] defaultTracker];
        [GAI sharedInstance].dispatchInterval = 20;
    }
    return self;
}

#pragma mark - Singleton

+ (instancetype)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t tocken;
    dispatch_once(&tocken, ^{
        sharedManager = [[self alloc] init];
    });
    
    return sharedManager;
}

#pragma mark - Public

- (void)trackDownloadedSpecialisation:(NSString *)specName
{
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Specialisation" action:@"Download" label:specName value:@1] build]];
}

- (void)trackNewDoctor
{
    if (![[NSUserDefaults standardUserDefaults] boolForKey:GAMDoctorCreated]) {
        [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Unique user" action:@"Created doctor profile" label:@"" value:@1] build]];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:GAMDoctorCreated];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    [self.tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"Doctor" action:@"Created doctor profile" label:@"" value:@1] build]];
}

@end
