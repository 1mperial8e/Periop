//
//  PE ImageDownloaderManager.h
//  ScrubUp
//
//  Created by Kirill on 12/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEImageDownloaderManager : NSObject

+ (instancetype)sharedManager;
- (void)startAsyncImagesDownloading;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString;
- (id)getDictionaryWithURL;
- (BOOL)saveObjectToUserDefaults:(id)object;

- (void)removeObservers;

@end
