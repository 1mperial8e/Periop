//
//  PECameraViewController.h
//  ScrubUp
//
//  Created by Stas Volskyi on 26.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PECameraViewController : UIViewController

typedef enum RequestedController : NSInteger RequestedController;

enum RequsetedController: NSInteger {
    OperationRoomViewController,
    DoctorsViewControllerAdd,
    DoctorsViewControllerProfile,
    EquipmentsToolViewController,
    NotesViewControllerAdd,
    PatientPostioningViewController
};

@property (strong, nonatomic) NSMutableArray *sortedArrayWithCurrentPhoto;
@property (assign, nonatomic) RequestedController request;

@end
