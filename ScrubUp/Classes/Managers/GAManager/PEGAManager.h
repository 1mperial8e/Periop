//
//  PEGAManager.h
//  ScrubUp
//
//  Created by Stas Volskyi on 30.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "GAI.h"

@interface PEGAManager : NSObject

@property (strong, nonatomic) id<GAITracker> tracker;

+ (instancetype)sharedManager;

- (void)trackDownloadedSpecialisation:(NSString *)specName;
- (void)trackSelectionOfSpecialisation:(NSString *)specName;
- (void)trackNewDoctor;

@end
