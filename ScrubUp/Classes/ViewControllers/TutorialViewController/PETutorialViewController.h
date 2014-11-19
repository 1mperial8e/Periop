//
//  TLViewController.h
//  Trill
//
//  Created by Anatoliy Dalekorey on 6/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PETutorialDelegate <NSObject>

@required
- (void)tutorialDidFinished;

@end

@interface PETutorialViewController : UIViewController

extern NSString *const TVCShowTutorial;

@property (weak, nonatomic) id<PETutorialDelegate> delegate;

@end
