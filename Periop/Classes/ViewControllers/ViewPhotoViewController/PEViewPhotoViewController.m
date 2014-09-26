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

@interface PEViewPhotoViewController ()

@property (weak, nonatomic) IBOutlet UIView *viewContainer;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) UILabel *navigationLabel;
@property (strong, nonatomic) CAGradientLayer *gradient;

@end

@implementation PEViewPhotoViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    self.specManager = [PESpecialisationManager sharedManager];    
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    
    self.navigationLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationLabel.textColor = [UIColor whiteColor];
    self.navigationLabel.minimumScaleFactor = 0.5;
    self.navigationLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationLabel.backgroundColor = [UIColor clearColor];
    self.navigationLabel.text = @"View Photo";
    
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
    self.navigationItem.titleView = self.navigationLabel ;
    if (self.photoToShow!=nil) {
        self.imageView.image = [UIImage imageWithData:self.photoToShow.photoData];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationLabel removeFromSuperview];
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
                }
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
