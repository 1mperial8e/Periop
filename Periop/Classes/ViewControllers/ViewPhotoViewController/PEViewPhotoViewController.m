//
//  PEViewPhotoViewController.m
//  Periop
//
//  Created by Kirill on 9/26/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

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
    
    self.navigationController.navigationBar.translucent = YES;
    
    UIBarButtonItem * backButton = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backButton;
    
    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.viewContainer.bounds;
    self.gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:248/255.0f green:243/255.0f blue:254/255.0f alpha:1.0f] CGColor],
                       (id)[[UIColor colorWithRed:201/255.0f green:234/255.0f blue:254/255.0f alpha:1.0f] CGColor], nil];
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
    
    ((PENavigationController *)self.navigationController).titleLabel.text = @"View Photo";
    
    if (self.photoToShow) {
        self.imageView.image = [UIImage imageWithData:self.photoToShow.photoData];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Rotation

- (void) canRotate
{
    //dummy
}

#pragma mark - IBActions

- (IBAction)removeImageButton:(id)sender
{
    if (self.photoToShow!=nil) {
        if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEOperationRoomViewController"]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.operationRoom.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.operationRoom removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEPatientPositioningViewController"]) {
            for (Photo * imageToDelete in [self.specManager.currentProcedure.patientPostioning.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentProcedure.patientPostioning removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else  if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEToolsDetailsViewController"]) {
            for (Photo * imageToDelete in [self.specManager.currentEquipment.photo allObjects]) {
                if ([imageToDelete.photoData isEqualToData:self.photoToShow.photoData]) {
                    [self.specManager.currentEquipment removePhotoObject:imageToDelete];
                    [self.managedObjectContext deleteObject:imageToDelete];
                }
            }
        } else  if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEDoctorProfileViewController"]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else  if ([[NSString stringWithFormat:@"%@",[self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString:@"PEAddEditDoctorViewController"]) {
            if ([self.specManager.currentDoctor.photo.photoData isEqualToData:self.photoToShow.photoData]) {
                [self.managedObjectContext deleteObject:self.specManager.currentDoctor.photo];
                self.specManager.currentDoctor.photo = nil;
            }
        } else if ([[NSString stringWithFormat:@"%@", [self.navigationController.viewControllers[[self.navigationController.viewControllers count]-2] class]] isEqualToString: @"PENotesViewController"]) {
            
            if ([((Photo*)self.specManager.currentNote.photo).photoData isEqualToData:self.photoToShow.photoData]) {
                if (self.specManager.currentNote.photo) {
                    [self.managedObjectContext deleteObject:(Photo*)self.specManager.currentNote.photo];
                }
                self.specManager.currentNote.photo = nil;
                
            }
        }

        NSError* removeError = nil;
        if (![self.managedObjectContext save:&removeError]) {
            NSLog(@"Cant remove image - %@", removeError.localizedDescription);
        }
        
        [self.navigationController popViewControllerAnimated:NO];
    }
    
}

@end
