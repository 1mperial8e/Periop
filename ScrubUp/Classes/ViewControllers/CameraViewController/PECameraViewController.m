	//
//  PECameraViewController.m
//  ScrubUp
//
//  Created by Stas Volskyi on 26.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PECameraViewController.h"
#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIImage+fixOrientation.h"
#import "PESpecialisationManager.h"
#import "PECoreDataManager.h"
#import "Photo.h"
#import "PatientPostioning.h"
#import "Note.h"
#import "PEAlbumViewController.h"

static void *CapturingStillImageContext = &CapturingStillImageContext;
static void *RecordingContext = &RecordingContext;
static void *SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface PECameraViewController ()

@property (weak, nonatomic) IBOutlet AVCamPreviewView *previewView;
@property (weak, nonatomic) IBOutlet UIButton *takePhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UIButton *flashButton;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) id runtimeErrorHandlingObserver;
@property (nonatomic) AVCaptureFlashMode currentFlashMode;

@property (strong, nonatomic) PESpecialisationManager *specManager;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PECameraViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    [self checkPhotoCount];
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
	[self setSession:session];
	
	[[self previewView] setSession:session];
    self.previewView.layer.zPosition = -320;
	
	[self checkDeviceAuthorizationStatus];
    
    self.currentFlashMode = AVCaptureFlashModeOff;
	
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
	
	dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
		
		NSError *error = nil;
		
		AVCaptureDevice *videoDevice = [PECameraViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
		
		if ([session canAddInput:videoDeviceInput]) {
			[session addInput:videoDeviceInput];
			[self setVideoDeviceInput:videoDeviceInput];
            
			dispatch_async(dispatch_get_main_queue(), ^{
				[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
			});
		}
		
		AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
		if ([session canAddOutput:stillImageOutput]) {
			[stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
			[session addOutput:stillImageOutput];
			[self setStillImageOutput:stillImageOutput];
		}
	});
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
        PECameraViewController *__weak weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:self.session queue:nil usingBlock:^(NSNotification *note) {
            PECameraViewController *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                [strongSelf.session startRunning];
            });
        }]];
        [self.session startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[self.session stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
        @try {
            [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
            [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
        }
        @catch (NSException *exception) {
            NSLog(@"Remove observer exception: %@", exception.debugDescription);
        }
		
	});
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

#pragma mark - UIActions

- (IBAction)takePhoto:(id)sender
{
    [self.takePhotoButton setEnabled:NO];
	dispatch_async([self sessionQueue], ^{
		[[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)self.previewView.layer connection] videoOrientation]];
		[PECameraViewController setFlashMode:self.currentFlashMode forDevice:self.videoDeviceInput.device];
		[self.stillImageOutput captureStillImageAsynchronouslyFromConnection:[self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
			
			if (imageDataSampleBuffer)
			{
				NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
				UIImage *image = [[UIImage alloc] initWithData:imageData];
                if ([UIDevice currentDevice].orientation == UIDeviceOrientationPortrait || [UIDevice currentDevice].orientation == UIDeviceOrientationPortraitUpsideDown) {
                    image = [image fixOrientation];
                } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight) {
                    image = [image fixLanscapeOrientationRight];
                } else if ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft) {
                    image = [image fixLanscapeOrientationLeft];
                }
                
                UIImageView *photoToShow = [[UIImageView alloc] initWithFrame:self.view.bounds];
                photoToShow.image = image;
                photoToShow.contentMode = UIViewContentModeScaleAspectFill;
                photoToShow.backgroundColor = [UIColor blackColor];
                [self.view addSubview:photoToShow];
                [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(hidePhotoView:) userInfo:nil repeats:NO];
                [self createPhotoObjectToStore:image];
			}
            [self.takePhotoButton setEnabled:YES];
		}];
	});
}

- (IBAction)close:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)turnFlash:(id)sender
{
    if (self.currentFlashMode == AVCaptureFlashModeOn) {
        self.currentFlashMode = AVCaptureFlashModeOff;
    } else {
        self.currentFlashMode = AVCaptureFlashModeOn;
    }
    ((UIButton *)sender).selected = !((UIButton *)sender).selected;
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0: {
            [self dismissViewControllerAnimated:YES completion:nil];
            break;
        }
    }
}

#pragma mark - Private

- (void)checkPhotoCount
{
    NSInteger allowedPhotoQuantity;
    
    if (self.request == OperationRoomViewController) {
        NSInteger photoCount = [self.specManager.currentProcedure.operationRoom.photo allObjects].count;
        allowedPhotoQuantity = AVCOperationRoomQuantity - photoCount;
        if (allowedPhotoQuantity < 0) {
            [self showCantAddPhotoNotification:(AVCOperationRoomQuantity + 1)];
        }
    } else if (self.request == EquipmentsToolViewController) {
        NSInteger photoCount =  [self.specManager.currentEquipment.photo allObjects].count;
        if (photoCount) {
            [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
        }
    } else if (self.request == DoctorsViewControllerProfile) {
        if (self.specManager.currentDoctor.photo) {
            [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
        }
    } else if(self.request == DoctorsViewControllerAdd) {
        if (self.specManager.currentDoctor) {
            if (self.specManager.currentDoctor.photo) {
                [self showCantAddPhotoNotification:(AVCOneQuantity + 1)];
            }
        }
    } else if (self.request == PatientPostioningViewController){
        NSInteger photoCount = [self.specManager.currentProcedure.patientPostioning.photo allObjects].count;
        allowedPhotoQuantity = AVCOperationRoomQuantity - photoCount;
        if (allowedPhotoQuantity < 0) {
            [self showCantAddPhotoNotification:(AVCOperationRoomQuantity + 1)];
        }
    }
}

- (void)showCantAddPhotoNotification:(NSInteger)allowedItemsCount
{
    NSString *message = [NSString stringWithFormat:@"You can add up to %i photos. Please delete some and try again.", (int)allowedItemsCount];
    [[[UIAlertView alloc] initWithTitle:@"Can't add photos" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
}


- (void)hidePhotoView:(NSTimer *)currentTimer
{
    [currentTimer invalidate];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)createPhotoObjectToStore:(UIImage *)imageToStore
{
    NSEntityDescription *photoEntity = [NSEntityDescription entityForName:@"Photo" inManagedObjectContext:self.managedObjectContext];
    Photo *newPhotoObject = [[Photo alloc] initWithEntity:photoEntity insertIntoManagedObjectContext:self.managedObjectContext];
    newPhotoObject.photoData = UIImageJPEGRepresentation(imageToStore, 1.0);
    
    self.specManager.photoObject = newPhotoObject;

    if (self.request == OperationRoomViewController) {
        if ([self.specManager.currentProcedure.operationRoom.photo allObjects].count<5) {
            newPhotoObject.operationRoom = self.specManager.currentProcedure.operationRoom;
            newPhotoObject.photoNumber = @([self.specManager.currentProcedure.operationRoom.photo allObjects].count + 1);
            [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhotoObject];
        } else {
            [self.managedObjectContext deleteObject:self.sortedArrayWithCurrentPhoto[0]];
            newPhotoObject.photoNumber = @0;
            newPhotoObject.operationRoom = self.specManager.currentProcedure.operationRoom;
            [self.specManager.currentProcedure.operationRoom addPhotoObject:newPhotoObject];
        }
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Cant save camera photo for operationRoom DB  - %@", error.localizedDescription);
        }
    } else if (self.request == PatientPostioningViewController) {
        newPhotoObject.patientPositioning = self.specManager.currentProcedure.patientPostioning;
        newPhotoObject.photoNumber = @([self.specManager.currentProcedure.patientPostioning.photo allObjects].count + 1);
        [self.specManager.currentProcedure.patientPostioning addPhotoObject:newPhotoObject];
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Cant save camera photo for patientPostioning DB  - %@", error.localizedDescription);
        }
    } else  if (self.request == EquipmentsToolViewController) {
        if ([self.specManager.currentEquipment.photo allObjects].count) {
            [self.managedObjectContext deleteObject:[self.specManager.currentEquipment.photo allObjects][0]];
            [self.specManager.currentEquipment removePhotoObject:[self.specManager.currentEquipment.photo allObjects][0]];
        }
        newPhotoObject.equiomentTool = self.specManager.currentEquipment;
        newPhotoObject.photoNumber = @0;
        [self.specManager.currentEquipment addPhotoObject:newPhotoObject];
        
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Cant save camera photo for equipment DB  - %@", error.localizedDescription);
        }
    } else if (self.request == NotesViewControllerAdd) {
        newPhotoObject.photoNumber = @0;
        [self.specManager.photoObjectsToSave addObject:newPhotoObject];
    } else if (self.request == DoctorsViewControllerProfile) {
        newPhotoObject.doctor = self.specManager.currentDoctor;
        newPhotoObject.photoNumber = @0;
        self.specManager.currentDoctor.photo = newPhotoObject;
        NSError *error = nil;
        if (![self.managedObjectContext save:&error]) {
            NSLog(@"Cant save camera photo for doctorsProfile DB - %@", error.localizedDescription);
        }
    } else if (self.request == DoctorsViewControllerAdd) {
        newPhotoObject.photoNumber = @0;
        self.specManager.photoObject = newPhotoObject;
    }
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted) {
			[self setDeviceAuthorized:YES];
		}
		else {
			dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"ScrubUp" message:@"Please provide access to camera througth device settings" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];                [self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return self.session.isRunning && self.isDeviceAuthorized;
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)self.previewView.layer connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	} else if (context == SessionRunningAndDeviceAuthorizedContext) {
		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
		
		dispatch_async(dispatch_get_main_queue(), ^{
			if (isRunning)
			{
				[self.takePhotoButton setEnabled:YES];
			}
			else
			{
				[self.takePhotoButton setEnabled:NO];
			}
		});
	} else {
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[self.previewView.layer setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[self.previewView.layer setOpacity:1.0];
		}];
	});
}

#pragma mark - Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode]) {
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode]) {
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode]) {
		NSError *error = nil;
		if ([device lockForConfiguration:&error]) {
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			captureDevice = device;
			break;
		}
	}
	return captureDevice;
}



@end
