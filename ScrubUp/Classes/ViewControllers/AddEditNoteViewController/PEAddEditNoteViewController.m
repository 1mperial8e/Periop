//
//  PEAddEditNoteViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMediaSelect.h"
#import "PEAddEditNoteViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "PECoreDataManager.h"
#import "PESpecialisationManager.h"
#import "Procedure.h"
#import "Doctors.h"
#import "Note.h"
#import "PEAlbumViewController.h"
#import "PECameraViewController.h"
#import "UIImage+ImageWithJPGFile.h"
#import "PELabelConfiguration.h"

@interface PEAddEditNoteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cornerLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UITextView *textViewNotes;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *PhotoButtonBottomPosition;

@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager *specManager;

@end

@implementation PEAddEditNoteViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.timeStamp.font = [UIFont fontWithName:FONT_MuseoSans500 size:12.0f];
    self.textViewNotes.font = [UIFont fontWithName:FONT_MuseoSans500 size:13.5f];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamedFile:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveUpdateNote:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    [saveButton setTitleTextAttributes:@{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans500 size:13.5f]} forState:UIControlStateNormal];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.cornerLabel.layer.cornerRadius = 24;
    self.cornerLabel.layer.borderColor = [UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1].CGColor;
    self.cornerLabel.layer.borderWidth = 1;
    
    if (self.noteTextToShow.length){
        self.textViewNotes.text = self.noteTextToShow;
    }
    if (self.timeToShow.length){
        self.timeStamp.text = self.timeToShow;
    } else {
        self.timeStamp.text = [self dateFormatter:[NSDate date]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameDidChanged:) name:UIKeyboardDidChangeFrameNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    ((PENavigationController *)self.navigationController).titleLabel.text = @"Note";
    
    [self.textViewNotes becomeFirstResponder];
    [[self.view viewWithTag:35] removeFromSuperview];
    if (!self.isEditNote) {
        ((PENavigationController *)self.navigationController).titleLabel.text = @"New Note";
        self.specManager.currentNote = nil;
    }
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.specManager.photoObject = nil;
    [self.specManager.photoObjectsToSave removeAllObjects];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - IBActions

- (IBAction)closeButton:(id)sender
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.specManager.photoObject) {
        [self.managedObjectContext deleteObject:self.specManager.photoObject];
    }
    [[PECoreDataManager sharedManager] save];

}

- (IBAction)saveUpdateNote:(id)sender
{
    if (self.isEditNote) {
        self.specManager.currentNote.textDescription = self.textViewNotes.text;
        self.specManager.currentNote.timeStamp = [NSDate date];
        if (self.specManager.photoObjectsToSave.count) {
            for (Photo *photo in self.specManager.photoObjectsToSave) {
                [self.specManager.currentNote addPhotoObject:photo];
            }
        }
    } else {
        NSEntityDescription *noteEntity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
        Note *newNote = [[Note alloc] initWithEntity:noteEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newNote.textDescription = self.textViewNotes.text;
        newNote.timeStamp = [NSDate date];
        
        self.specManager.currentNote = newNote;
        if (self.specManager.photoObjectsToSave.count) {
            for (Photo *photo in self.specManager.photoObjectsToSave) {
                photo.note = self.specManager.currentNote;
                [newNote addPhotoObject:photo];
                photo.note = newNote;
            }
        }
        if (self.specManager.isProcedureSelected) {
            [((Procedure*)self.specManager.currentProcedure) addNotesObject:newNote];
        } else {
            [((Doctors*)self.specManager.currentDoctor) addNotesObject:newNote];
        }
    }

    [[PECoreDataManager sharedManager] save];

    
    [self.specManager.photoObjectsToSave removeAllObjects];
    self.specManager.currentNote = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.mainView.frame;
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect *view = [array firstObject];
    view.frame = position;
    view.tag = 35;
    
    [view addSubview:[PELabelConfiguration setInformationLabelOnView:view]];
    
    [self.textViewNotes endEditing:YES];
    [self.view addSubview:view];
    [view setVisible:YES];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    
    if (self.specManager.isProcedureSelected) {
        albumViewController.navigationLabelText = ((Procedure *)self.specManager.currentProcedure).name;
    } else {
        albumViewController.navigationLabelText = ((Doctors *)self.specManager.currentDoctor).name;
    }
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    NSLog(@"camera Photo ");
    PECameraViewController *cameraView = [[PECameraViewController alloc] initWithNibName:@"PECameraViewController" bundle:nil];
    cameraView.request = NotesViewControllerAdd;
    [self presentViewController:cameraView animated:YES completion:nil];
}

- (IBAction)tapOnView:(id)sender
{
    [self.textViewNotes becomeFirstResponder];
    [(PEMediaSelect *)[self.view viewWithTag:35] setVisible:NO];
}

#pragma mark - Private

- (NSString *)dateFormatter:(NSDate *)dateToFormatt
{
    NSDateFormatter *dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter *dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

- (void)keyboardFrameDidChanged:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    if (endFrame.size.height > 200) {
        [UIView animateWithDuration:1.2 animations:^{
            self.PhotoButtonBottomPosition.constant = endFrame.size.height + 10;
        }];
    }
}

@end
