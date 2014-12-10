//
//  PETermsAndConditionViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const TACTermsAndConditions = @"Terms & Conditions";

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
    NSString *mainContent = [self readFileSource];
    if (mainContent.length) {
        self.textView.attributedText = [self getFormattedString:mainContent];
    } else {
        NSLog(@"Cant read source file");
    }
}

- (NSString *)readFileSource
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"TermsAndConditions" ofType:@"txt"];
    NSError *fileReadingError;
    NSString *mainContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadingError];
    return mainContent;
}

- (NSMutableAttributedString *)getFormattedString:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    NSDictionary *attributes = @{NSFontAttributeName : [UIFont fontWithName:FONT_MuseoSans300 size:13.5f], NSParagraphStyleAttributeName : style};
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
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
