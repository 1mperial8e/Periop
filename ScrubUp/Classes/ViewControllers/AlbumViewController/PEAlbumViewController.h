//
//  PEAlbumViewController.h
//  ScrubUp
//
//  Created by Stas Volskyi on 19.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const AVCOperationRoomViewController = @"PEOperationRoomViewController";
static NSString *const AVCToolsDetailsViewController = @"PEToolsDetailsViewController";
static NSString *const AVCPatientPositioningViewController = @"PEPatientPositioningViewController";
static NSString *const AVCDoctorProfileViewController = @"PEDoctorProfileViewController";
static NSString *const AVCAddEditDoctorViewController = @"PEAddEditDoctorViewController";
static NSString *const AVCAddEditNoteViewController = @"PEAddEditNoteViewController";

static NSInteger const AVCOperationRoomQuantity = 4;
static NSInteger const AVCOneQuantity = 0;
static NSInteger const AVCDefaultQuantity = 29;

@interface PEAlbumViewController : UIViewController

@property (strong, nonatomic) NSString *navigationLabelText;
@property (strong, nonatomic) NSMutableArray *sortedArrayWithCurrentPhoto;

@end
