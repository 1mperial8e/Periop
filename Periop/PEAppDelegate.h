//
//  PEAppDelegate.h
//  Periop
//
//  Created by Stas Volskyi on 04.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PEAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
