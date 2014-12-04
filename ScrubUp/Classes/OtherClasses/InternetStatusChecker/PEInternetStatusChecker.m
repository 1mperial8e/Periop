//
//  PEInternetStatusChecker.m
//  ScrubUp
//
//  Created by Kirill on 11/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEInternetStatusChecker.h"

@implementation PEInternetStatusChecker

+ (BOOL)isInternetAvaliable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return networkStatus != NotReachable;
}

+ (BOOL)isWIFIInternetAvaliable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWiFi) {
        return YES;
    }
    return NO;
}

+ (BOOL)is3GInternetAvaliable
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    if (networkStatus == ReachableViaWWAN) {
        return YES;
    }
    return NO;
}

@end
