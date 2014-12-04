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

@interface PEImageDownloaderManager(){
    dispatch_queue_t customSerialQueue;
}

@property (strong, nonatomic) EquipmentsTool *equipmentToUpdate;

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

- (instancetype)init
{
    if (self = [super init]) {
        [self setupAppNotification];
    }
    return self;
}

#pragma mark - Public

- (BOOL)saveObjectToUserDefaults:(id)object
{
    [[NSUserDefaults standardUserDefaults] setObject:object forKey:kLinkDictionary];
    if (![[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"Cant save updated userDefaults");
    }
    return YES;
}

- (id)getDictionaryWithURL
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kLinkDictionary];
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
                } else {
                    [strongSelf showAlertNo3GAllowed];
                }
            }
            [strongSelf showAlertNoInternetAvaliable];
        }
    });
}

#pragma mark - Private

- (BOOL)is3GAllowedByUser
{
    //todo
    return YES;
}

- (void)prepareToDownloadImages
{
    NSMutableDictionary *dictionaryURL = [self getDictionaryWithURL];
    NSMutableArray *keys = [[dictionaryURL allKeys] mutableCopy];
    
    if (dictionaryURL.count) {
        for (NSString *dateKeyString in keys) {
            if ([self isImageNeedToBeDownloadedForEquipmentWithKey:dateKeyString]) {
                [self updatePhotoForSelectedEntityFrom:[dictionaryURL valueForKey:dateKeyString]];
            }
            [dictionaryURL removeObjectForKey:dateKeyString];
            [self saveObjectToUserDefaults:dictionaryURL];
        }
    }
}

#pragma mark - DBRequest

- (BOOL)isImageNeedToBeDownloadedForEquipmentWithKey:(NSString *)dateKey
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:@"EquipmentsTool"  inManagedObjectContext: [[PECoreDataManager sharedManager] managedObjectContext]];
    [fetchRequest setEntity:entityDescription];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"(ANY createdDate contains[cd] %@)",[[PEImageDownloaderManager sharedManager] dateFromString:dateKey]]];
    NSError * error;
    NSArray *fetchedResult = [[[PECoreDataManager sharedManager] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    
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
           
//             dispatch_async(dispatch_get_main_queue(), ^{
//                 @synchronized (self) {
                    NSError *saveError;
                    if (![[[PECoreDataManager sharedManager] managedObjectContext] save:&saveError]) {
                        NSLog(@"Cant save photo to Equipment - %@", self.equipmentToUpdate.name);
                    } else {
                        NSLog(@"Entity  EquipmentTool - %@ updated", self.equipmentToUpdate.name);
                    }
                 }
//             });
//        }
    }
}

#pragma mark - Alerts

- (NSString *)appName
{
    return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
}

- (void)showAlertNo3GAllowed
{
    NSString *message = [NSString stringWithFormat:@"3G Internet accsess not allowed for %@. To allow, please go to settings and change permissions", [self appName]];
    [[[UIAlertView alloc] initWithTitle:[self appName] message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

- (void)showAlertNoInternetAvaliable
{
    [[[UIAlertView alloc] initWithTitle:[self appName] message:@"No internet connection" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}

#pragma mark - Notification

- (void)setupAppNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didEnterBackground
{
    dispatch_suspend(customSerialQueue);
    NSLog(@"Downloading queue suspended");
}

- (void)willEnterForeground
{
    if (customSerialQueue) {
        dispatch_resume(customSerialQueue);
    } else {
        [self startAsyncImagesDownloading];
        NSLog(@"Created new queue");
    }
    NSLog(@"Downloading queue resumed");
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
