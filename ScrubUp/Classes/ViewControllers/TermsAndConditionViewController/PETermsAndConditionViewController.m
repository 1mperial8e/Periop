//
//  PETermsAndConditionViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const TACTermsAndConditions = @"Terms & Conditions";
static NSString *const TACCaptionMain = @"DEED OF AGREEMENT FOR “SCRUBUP” USAGE – USER TERMS AND CONDITIONS \n\n";
static NSString *const TACCaptionRecitals = @"RECITALS\n";
static NSString *const TACCAptionAgreed = @"IT IS AGREED\n";

#import "PETermsAndConditionViewController.h"
#import "PEMenuViewController.h"

@interface PETermsAndConditionViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation PETermsAndConditionViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self configureTextView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    ((PENavigationController *)self.navigationController).titleLabel.text = TACTermsAndConditions;
}

#pragma mark - Private

- (void)configureTextView
{
    self.textView.attributedText = [self generateFormattedText];
}

- (NSString *)readTextPartFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSError *fileReadingError;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadingError];
    return fileContent;
}

- (NSMutableAttributedString *)getFormattedString:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans300 size:13.5f], NSParagraphStyleAttributeName : style};
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSMutableAttributedString *)getFormattedCaption:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans300 size:13.5f], NSParagraphStyleAttributeName : style};
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSMutableAttributedString *)generateFormattedText
{
    NSMutableAttributedString *partOne = [self getFormattedString:[self readTextPartFile:@"TermsAndConditions_part1"]];
    NSMutableAttributedString *partTwo = [self getFormattedString:[self readTextPartFile:@"TermsAndConditions_part2"]];
    NSMutableAttributedString *partThree = [self getFormattedString:[self readTextPartFile:@"TermsAndConditions_part3"]];
    
    NSMutableAttributedString *mainCaption = [self getFormattedCaption:TACCaptionMain];
    NSMutableAttributedString *recitalsCaption = [self getFormattedCaption:TACCaptionRecitals];
    NSMutableAttributedString *agreedCaption = [self getFormattedCaption:TACCAptionAgreed];
    
    [mainCaption appendAttributedString:partOne];
    [mainCaption appendAttributedString:recitalsCaption];
    [mainCaption appendAttributedString:partTwo];
    [mainCaption appendAttributedString:agreedCaption];
    [mainCaption appendAttributedString:partThree];
    
    return mainCaption;
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:@"PEMenuViewController" bundle:nil];
    menuController.textToShow = TACTermsAndConditions;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
#ifdef __IPHONE_8_0
    menuController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

@end
