//
//  PEMenuViewController.h
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PEMenuViewController : UIViewController

@property (strong, nonatomic) NSString * textToShow;
@property (assign, nonatomic) NSInteger buttonPositionY;
@property (assign, nonatomic) BOOL isButtonVisible;
@property (assign, nonatomic) CGFloat sizeOfFontInNavLabel;
@property (weak, nonatomic) IBOutlet UIView *viewSelection;
@property (weak, nonatomic) IBOutlet UIButton *specializationButton;

@end
