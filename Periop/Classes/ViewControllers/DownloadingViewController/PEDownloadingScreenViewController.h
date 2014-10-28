//
//  PEDownloadingScreenViewController.h
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEDownloadingVCDelegate <NSObject>

@optional
- (void)dataDidChanged;

@end

@interface PEDownloadingScreenViewController : UIViewController

@property (strong, nonatomic) NSDictionary *specialisationInfo;
@property (assign, nonatomic) BOOL isInitialConfig;

@property (weak, nonatomic) id<PEDownloadingVCDelegate> delegate;

@end
