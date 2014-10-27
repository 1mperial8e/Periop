//
//  PEViewPhotoViewController.h
//  Periop
//
//  Created by Kirill on 9/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "Photo.h"

@interface PEViewPhotoViewController : UIViewController

@property (strong, nonatomic) Photo *photoToShow;
@property (assign, nonatomic) NSInteger startPosition;

@end
