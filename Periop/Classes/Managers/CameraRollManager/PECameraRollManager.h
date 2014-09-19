//
//  PECameraRollManager.h
//  Periop
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>

@interface PECameraRollManager : NSObject

@property (strong, nonatomic) NSMutableArray *assets;

+ (instancetype)sharedInstance;
- (void)getPhotosFromCameraRoll;

@end
