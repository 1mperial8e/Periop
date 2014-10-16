//
//  PEAddEditStepViewControllerViewController.h
//  Periop
//
//  Created by Stas Volskyi on 16.10.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

typedef NS_ENUM (NSInteger, PEStepEntityName) {
    PEStepEntityNamePreparation,
    PEStepEntityNameOperationRoom,
    PEStepEntityNamePatientPositioning
};

@interface PEAddEditStepViewControllerViewController : UIViewController

@property (strong, nonatomic) NSString *stepNumber;
@property (strong, nonatomic) NSString *stepText;

@property (assign, nonatomic) PEStepEntityName entityName;

@end
