//
//  PEViewPhotoViewController.m
//  Periop
//
//  Created by Kirill on 9/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const VPVCOperationRoomViewController = @"PEOperationRoomViewController";
static NSString *const VPVCToolsDetailsViewController = @"PEToolsDetailsViewController";
static NSString *const VPVCPatientPositioningViewController = @"PEPatientPositioningViewController";
static NSString *const VPVCDoctorProfileViewController = @"PEDoctorProfileViewController";
static NSString *const VPVCAddEditDoctorViewController = @"PEAddEditDoctorViewController";
static NSString *const VPVCNotesViewController = @"PENotesViewController";

#import "PEViewPhotoViewController.h"
#import "PESpecialisationManager.h"
#import "PECoreDatamanager.h"
#import "PatientPostioning.h"
#import "Note.h"

@interface PEViewPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation PEViewPhotoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];

    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.viewContainer.bounds;
    self.gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xF5F3FE) CGColor], (id)[UIColorFromRGB(0xC9EAFE) CGColor], nil];
    [self.viewContainer.layer insertSublayer:self.gradient atIndex:0];
    
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect bounds = self.gradient.bounds;
    if (toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
        bounds.size.width = self.view.bounds.size.width + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    } else {
        bounds.size.width = self.view.bounds.size.height + self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    }
    self.gradient.frame = bounds;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.text = @"View Photo";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:20];
    self.navigationItem.titleView = titleLabel;
    ((PENavigationController *)self.navigationController).titleLabel.text = @"";
    
    if (self.photoToShow) {
        self.imageView.image = [UIImage imageWithData:self.photoToShow.photoData];
    }
}

#pragma mark - Rotation

- (void)canRotate
{
    //dummy
}

#pragma mark - IBActions

- (IBAction)removeImageButton:(id)sender
{
    if (self.photoToShow) {
        id viewController = self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2];
        
        if ([viewController isKindOfClass:NSClassFromString(VPVCOperationRoomViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.operationRoom.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.operationRoom removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCPatientPositioningViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.patientPostioning.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.patientPostioning removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCToolsDetailsViewController)]) {
            for (Photo * imageToDelete in [self.specManager.currentEquipment.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentEquipment removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCDoctorProfileViewController)]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCAddEditDoctorViewController)]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else if ([viewController isKindOfClass:NSClassFromString(VPVCNotesViewController)]) {
            if ([((Photo*)self.specManager.currentNote.photo).photoData isEqualToData:self.photoToShow.photoData]) {
                if (self.specManager.currentNote.photo) {
                    [self.managedObjectContext deleteObject:(Photo*)self.specManager.currentNote.photo];
                }
                self.specManager.currentNote.photo = nil;
            }
        }
        NSError* removeError;
        if (![self.managedObjectContext save:&removeError]) {
            NSLog(@"Cant remove image - %@", removeError.localizedDescription);
        }        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
