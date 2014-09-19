//
//  PECameraRollManager.m
//  Periop
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PECameraRollManager.h"

@interface PECameraRollManager()

@property (strong, atomic) ALAssetsLibrary *assetsLibrary;

@end

@implementation PECameraRollManager

+ (instancetype)sharedInstance
{
    static id sharedInstance = nil;
    static dispatch_once_t onceTocken;
    dispatch_once(&onceTocken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
        self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    return self;
}

#pragma mark - Public

- (void)getPhotosFromCameraRoll
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^(void) {
        [self.assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [self.assets addObject:result];
                }
            }];
            if (!group) {
                self.assets = [self reversedAssets];
            }
        } failureBlock:^(NSError *error) {
            NSLog(@"Error loading images %@", error);
        }];
    });
}

#pragma mark - Private

- (NSMutableArray *)reversedAssets {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.assets.count];
    NSEnumerator *enumerator = [self.assets reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    return array;
}

@end
