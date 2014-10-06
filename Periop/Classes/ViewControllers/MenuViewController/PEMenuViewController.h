//
//  PEMenuViewController.h
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

typedef NS_ENUM (NSInteger, PESpecList) {
    PESpecListMySpecialisations,
    PESpecListMoreSpecialisations
};

@protocol SpecialisationListDelegate <NSObject>

@optional
- (void)specialisationsListChanged:(PESpecList)specList;

@end

@interface PEMenuViewController : UIViewController

@property (strong, nonatomic) NSString *textToShow;
@property (assign, nonatomic) NSInteger buttonPositionY;
@property (assign, nonatomic) BOOL isButtonMySpecializations;
@property (assign, nonatomic) CGFloat sizeOfFontInNavLabel;
@property (weak, nonatomic) IBOutlet UIView *viewSelection;

@property (weak, nonatomic) id<SpecialisationListDelegate> delegate;

@end
