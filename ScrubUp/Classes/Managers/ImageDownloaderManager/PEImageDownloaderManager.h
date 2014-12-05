//
//  PE ImageDownloaderManager.h
//  ScrubUp
//
//  Created by Kirill on 12/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEImageDownloaderManager : NSObject

+ (instancetype)sharedManager;
- (void)startBackgroundAsyncImageDownloading;
- (void)startAsyncDownloadingIfQueueCreated;

- (void)suspendAsyncQueue;
- (void)resumeAsyncQueue;

- (NSString *)stringFromDate:(NSDate *)date;
- (NSDate *)dateFromString:(NSString *)dateString;
- (NSString *)uniqueKey;

- (NSDictionary *)getDictionaryWithURL;
- (BOOL)saveObjectToUserDefaults:(NSMutableDictionary *)newUrlsDictionary isNew:(BOOL)newIndicator;

- (void)removeObservers;

@end
