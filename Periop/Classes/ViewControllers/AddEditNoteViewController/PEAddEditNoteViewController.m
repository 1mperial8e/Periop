//
//  PEAddEditNoteViewController.m
//  Periop
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

@interface PEAddEditNoteViewController ()

@property (weak, nonatomic) IBOutlet UILabel *cornerLabel;
@property (weak, nonatomic) IBOutlet UIView *mainView;
@property (weak, nonatomic) IBOutlet UILabel *timeStamp;
@property (weak, nonatomic) IBOutlet UITextView *textViewNotes;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (strong, nonatomic) NSManagedObjectContext * managedObjectContext;
@property (strong, nonatomic) PESpecialisationManager * specManager;

@end

@implementation PEAddEditNoteViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.specManager = [PESpecialisationManager sharedManager];
    self.managedObjectContext = [[PECoreDataManager sharedManager] managedObjectContext];
    
    CGSize navBarSize = self.navigationController.navigationBar.frame.size;
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, navBarSize.width - navBarSize.height * 2,  navBarSize.height)];
    self.navigationBarLabel.minimumScaleFactor = 0.5;
    self.navigationBarLabel.adjustsFontSizeToFitWidth = YES;
    self.navigationBarLabel.center = CGPointMake(navBarSize.width/2, navBarSize.height/2);
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel.font = [UIFont fontWithName:@"MuseoSans-300" size:20.0];
    self.navigationBarLabel.text = @"New Note";
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;

    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"Close"] style:UIBarButtonItemStyleBordered target:self action:@selector(closeButton:)];
    self.navigationItem.leftBarButtonItem = closeButton;
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveUpdateNote:)];
    self.navigationItem.rightBarButtonItem = saveButton;
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.textViewNotes.layer.cornerRadius = 24;
    self.cornerLabel.layer.cornerRadius = 24;
    self.cornerLabel.layer.borderColor = [[UIColor colorWithRed:224/255.0 green:224/255.0 blue:224/255.0 alpha:1] CGColor];
    self.cornerLabel.layer.borderWidth = 1;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.noteTextToShow.length>0){
        self.textViewNotes.text = self.noteTextToShow;
    }
    if (self.timeToShow.length>0){
        self.timeStamp.text = self.timeToShow;
    } else {
        self.timeStamp.text = [self dateFormatter:[NSDate date]];
    }
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)closeButton :(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveUpdateNote :(id)sender
{
    if (self.isEditNote) {
            self.specManager.currentNote.textDescription = self.textViewNotes.text;
            self.specManager.currentNote.timeStamp = [NSDate date];
    } else {
        NSEntityDescription * noteEntity = [NSEntityDescription entityForName:@"Note" inManagedObjectContext:self.managedObjectContext];
        Note * newNote = [[Note alloc] initWithEntity:noteEntity insertIntoManagedObjectContext:self.managedObjectContext];
        newNote.textDescription = self.textViewNotes.text;
        newNote.timeStamp = [NSDate date];
        if (self.specManager.isProcedureSelected) {
            [((Procedure*)(self.specManager.currentProcedure)) addNotesObject:newNote];
        } else {
            [((Doctors*)(self.specManager.currentDoctor)) addNotesObject:newNote];
        }
    }
    
    NSError * saveError = nil;
    if (![self.managedObjectContext save:&saveError]){
        NSLog(@"Cant add new Note - %@", saveError.localizedDescription);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)photoButton:(id)sender
{
    CGRect position = self.mainView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender
{
    PEAlbumViewController *albumViewController = [[PEAlbumViewController alloc] initWithNibName:@"PEAlbumViewController" bundle:nil];
    
    if (self.specManager.isProcedureSelected) {
        albumViewController.navigationLabelText = ((Procedure*)(self.specManager.currentProcedure)).name;
    } else {
        albumViewController.navigationLabelText = ((Doctors*)(self.specManager.currentDoctor)).name;
    }
    
    [self.navigationController pushViewController:albumViewController animated:YES];
}

- (IBAction)cameraPhoto:(id)sender
{
    NSLog(@"camera Photo ");
}

- (IBAction)tapOnView:(id)sender
{
    [[self.view viewWithTag:35] removeFromSuperview];
}

#pragma mark - Private

- (NSString*)dateFormatter: (NSDate*)dateToFormatt
{
    NSDateFormatter * dateFormatterTimePart = [[NSDateFormatter alloc] init];
    [dateFormatterTimePart setDateFormat:@"dd MMMM YYYY, h:mm"];
    NSDateFormatter * dateFormatterDayPart = [[NSDateFormatter alloc] init];
    [dateFormatterDayPart setDateFormat:@"aaa"];
    return [NSString stringWithFormat:@"%@%@",[dateFormatterTimePart stringFromDate:dateToFormatt],[[dateFormatterDayPart stringFromDate:dateToFormatt] lowercaseString]];
}

@end
