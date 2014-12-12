//
//  PE ImageDownloaderManager.m
//  ScrubUp
//
//  Created by Kirill on 12/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEImageDownloaderManager.h"
#import "PEInternetStatusChecker.h"
#import "PECoreDataManager.h"
#import "EquipmentsTool.h"
#import "Photo.h"
#import "PECsvParser.h"

@interface PEImageDownloaderManager() {
    dispatch_queue_t customSerialQueue;
}

@property (strong, nonatomic) EquipmentsTool *equipmentToUpdate;
@property (strong, atomic) PECoreDataManager *coreDataManager;
@property (assign, nonatomic) NSInteger startURLCount;
@property (assign, nonatomic) BOOL isDictionaryURLsUpdated;

@property (strong, nonatomic) PECsvParser *activityMonitor;

@end

@implementation PEImageDownloaderManager

#pragma mark - LifeCycle

+ (instancetype)sharedManager
{
    static PEImageDownloaderManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[PEImageDownloaderManager alloc] init];
    });
    return sharedManager;
}

#pragma mark - Initialisation

- (instancetype)init
{
    if (self = [super init]) {
        [self setupAppNotification];
        [self setStartQuantityOfURLs];
        self.coreDataManager = [[PECoreDataManager alloc] initCoreDataManager];
    }
    return self;
}

#pragma mark - Public

- (void)suspendAsyncQueue
{
    if (customSerialQueue) {
        dispatch_suspend(customSerialQueue);
        NSLog(@"Downloading queue suspended");
    }
}

- (void)resumeAsyncQueue
{
    if (customSerialQueue) {
        dispatch_resume(customSerialQueue);
        NSLog(@"Downloading queue resumed");
    }
}

- (BOOL)saveObjectToUserDefaults:(NSMutableDictionary *)newUrlsDictionary isNew:(BOOL)newIndicator
{
    if (([self getDictionaryWithURL].count && [self getDictionaryWithURL].count > self.startURLCount) ||
        newIndicator) {
        NSMutableDictionary *oldURLs = [[self getDictionaryWithURL] mutableCopy];
        [newUrlsDictionary addEntriesFromDictionary:oldURLs];
        self.startURLCount = newUrlsDictionary.count;
        self.isDictionaryURLsUpdated = YES;
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:newUrlsDictionary forKey:kLinkDictionary];
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"Cant save updated userDefaults");
    }
    return YES;
}

- (NSMutableDictionary *)getDictionaryWithURL
{
    return [[[NSUserDefaults standardUserDefaults] objectForKey:kLinkDictionary] mutableCopy];
}

- (NSString *)stringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat: @"yyyy-MM-dd-HH:mm:ss:SSSS zzz"];
    NSString *dateStr = [dateFormatter stringFromDate:date];
    return dateStr;
}

- (NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd-HH:mm:ss:SSSS zzz"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (NSString *)uniqueKey
{
    CFUUIDRef uuidRef = CFUUIDCreate(NULL);
    CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
    CFRelease(uuidRef);
    return (__bridge_transfer NSString *)uuidStringRef;
}

- (void)startBackgroundAsyncImageDownloading
{
    if ([self getDictionaryWithURL].count) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self startAsyncImagesDownloading];
        });
    }
}

- (void)startAsyncDownloadingIfQueueCreated
{
    if (customSerialQueue) {
        [self startAsyncImagesDownloading];
    }
}

#pragma mark - Private

- (void)startAsyncImagesDownloading
{
    customSerialQueue = dispatch_queue_create("imageDownloadingAsyncQueue", NULL);
    __weak PEImageDownloaderManager *weakSelf = self;
    dispatch_async(customSerialQueue, ^{
        PEImageDownloaderManager *strongSelf = weakSelf;
        if ([PEInternetStatusChecker isWIFIInternetAvaliable]) {
            [strongSelf prepareToDownloadImages];
        } else {
            if ([PEInternetStatusChecker is3GInternetAvaliable]) {
                if ([strongSelf is3GAllowedByUser]) {
                    [strongSelf prepareToDownloadImages];
                }
            }
        }
    });
}

- (BOOL)is3GAllowedByUser
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"allowMobileNetwork"];
}

- (void)prepareToDownloadImages
{
    self.isDownloadingActive = YES;
    NSMutableDictionary *dictionaryURL = [[self getDictionaryWithURL] mutableCopy];
    NSMutableArray *keys = [[dictionaryURL allKeys] mutableCopy];

    if (dictionaryURL.count) {
        for (NSString *uniqueKeyString in keys) {
            if ([PEInternetStatusChecker isInternetAvaliable]) {
                if ([self isImageNeedToBeDownloadedForEquipmentWithKey:uniqueKeyString]) {
                    [self updatePhotoForSelectedEntityFrom:[dictionaryURL valueForKey:uniqueKeyString]];
                }
                if (self.isDictionaryURLsUpdated) {
                    dictionaryURL = [[self getDictionaryWithURL] mutableCopy];
                    self.isDictionaryURLsUpdated = NO;
                }
                [dictionaryURL removeObjectForKey:uniqueKeyString];
                [self saveObjectToUserDefaults:dictionaryURL isNew:NO];
              //  NSLog(@"Need to update - %i entities", dictionaryURL.count);
            }
        }
    }
    dictionaryURL = [[self getDictionaryWithURL] mutableCopy];
    if (dictionaryURL.count) {
        [self startAsyncDownloadingIfQueueCreated];
    }
    self.isDownloadingActive = NO;
}

- (void)setStartQuantityOfURLs
{
    NSMutableDictionary *dictionaryWithURLs = [[[NSUserDefaults standardUserDefaults] objectForKey:kLinkDictionary] mutableCopy];
    self.startURLCount = dictionaryWithURLs.count;
}

#pragma mark - DBRequest

- (BOOL)isImageNeedToBeDownloadedForEquipmentWithKey:(NSString *)uniqueKey
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"EquipmentsTool"  inManagedObjectContext: [[PECoreDataManager sharedManager] managedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(uniqueKey == %@)", uniqueKey]];
    NSError * error;
    NSArray *fetchedResult = [[self.coreDataManager managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
    if (fetchedResult.count) {
        EquipmentsTool *selectedEquipment = fetchedResult[0];
        if ([selectedEquipment.photo allObjects].count) {
            if (((Photo *)[selectedEquipment.photo allObjects][0]).photoData) {
                return NO;
            } else {
                self.equipmentToUpdate = selectedEquipment;
                return YES;
            }
        }
    }
    return NO;
}

- (void)updatePhotoForSelectedEntityFrom:(NSString *)stringURL
{
    if (self.equipmentToUpdate) {
        NSURL *imgURL = [NSURL URLWithString:stringURL];
        NSData *imageData = [NSData dataWithContentsOfURL:imgURL];
        if (imageData) {
            ((Photo *)[self.equipmentToUpdate.photo allObjects][0]).photoData = imageData;
            
            [self.coreDataManager.persistentStoreCoordinator lock];
            
            NSError *saveError;
            if (![[self.coreDataManager managedObjectContext] save:&saveError]) {
                NSLog(@"Cant save photo to Equipment - %@, %@", self.equipmentToUpdate.name, saveError.localizedDescription);
            } else {
                NSLog(@"Entity  EquipmentTool - %@ updated", self.equipmentToUpdate.name);
            }
            
            [self.coreDataManager.persistentStoreCoordinator unlock];
        }
    }
}

#pragma mark - Alerts

- (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

#pragma mark - Notification

- (void)setupAppNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didEnterBackground
{
    [self suspendAsyncQueue];
}

- (void)willEnterForeground
{
    [self resumeAsyncQueue];
}

- (BOOL)isQueueStillActive
{
    return YES;
}

#pragma mark - CleanUp

- (void)removeObservers
{
    @try {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    @catch (NSException *ex) {
        NSLog(@"Cant remove observer in ImageDownloadersManager - %@", ex.description);
    }
}

- (void)dealloc
{
    [self removeObservers];
}

@end
