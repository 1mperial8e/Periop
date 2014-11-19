//
//  PEAboutUsViewController.m
//  ScrubUp
//
//  Created by Kirill on 9/6/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

static NSString *const AUVCTitleText = @"About Us";
static NSString *const AUVCNibName = @"PEMenuViewController";

static NSString *const AUVCTwitterKey = @"twitter";
static NSString *const AUVCFaceBookKey = @"faceBook";
static NSString *const AUVCEmailKey = @"email";
static NSString *const AUVCFacebookLink = @"https://www.facebook.com/pages/Allis-Technology/572060062899260";
static NSString *const AUVCTwitterLink = @"https://twitter.com/ScrubUpU";

#import "PEAboutUsViewController.h"
#import "PEMenuViewController.h"
#import <MessageUI/MessageUI.h>
#import "PEMailControllerConfigurator.h"

@interface PEAboutUsViewController () <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (copy, nonatomic) NSMutableAttributedString *textToShow;
@property (strong, nonatomic) MFMailComposeViewController *mailController;

@end

@implementation PEAboutUsViewController

#pragma mark - LifeCycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureTextView];
    [self setupGesture];
    [self setupViewController];
}

#pragma mark - IBActions

- (IBAction)menuButton:(id)sender
{
    PEMenuViewController *menuController = [[PEMenuViewController alloc] initWithNibName:AUVCNibName bundle:nil];
    menuController.textToShow = AUVCTitleText;
    menuController.buttonPositionY = self.navigationController.navigationBar.frame.size.height;
#ifdef __IPHONE_8_0
    menuController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationCurrentContext;
    [rootController presentViewController:menuController animated:NO completion:nil];
}

#pragma mark - Private

- (void)setupViewController
{
    ((PENavigationController *)self.navigationController).titleLabel.text = AUVCTitleText;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void)configureTextView
{
    NSString *mainContent = [self readFileSource];
    if (mainContent.length) {
        NSMutableAttributedString *aboutContent = [self combineAboutContent:mainContent];
        self.textView.attributedText = aboutContent;
    } else {
        NSLog(@"Cant read source file");
    }
}

- (NSString *)readFileSource
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"AboutUs" ofType:@"txt"];
    NSError *fileReadingError;
    NSString *mainContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadingError];
    return mainContent;
}

- (NSMutableAttributedString *)combineAboutContent:(NSString *)mainContent
{
    NSMutableAttributedString *content = [self getFormattedString:mainContent];
    
    NSMutableAttributedString *twitter = [self configureLinkWithString:@"ScrubUp@ScrubupU" forKey:AUVCTwitterKey tintColor:UIColorFromRGB(0x4B9DE1)];
    NSMutableAttributedString *email = [self configureLinkWithString:@"Scrubup@Allistechnology.com.au" forKey:AUVCEmailKey tintColor:UIColorFromRGB(0x4B9DE1)];
    NSMutableAttributedString *faceBook = [self configureLinkWithString:@"Allis Technology" forKey:AUVCFaceBookKey tintColor:UIColorFromRGB(0x4B9DE1)];
    
    [content appendAttributedString:[self getFormattedString:@"\n\nTwitter: "]];
    [content appendAttributedString:twitter];
        [content appendAttributedString:[self getFormattedString:@"\n\nEmail: "]];
    [content appendAttributedString:email];
        [content appendAttributedString:[self getFormattedString:@"\n\nFacebook: "]];
    [content appendAttributedString:faceBook];
    
    return content;
}

- (NSMutableAttributedString *)configureLinkWithString:(NSString *)string forKey:(NSString *)key tintColor:(UIColor *)color
{
    NSMutableAttributedString *linkString = [[NSMutableAttributedString alloc] initWithString:string attributes:@{ key : @(YES) }];
    [linkString addAttribute:NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans300 size:13.5f] range:NSMakeRange(0, linkString.length)];
    [linkString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, linkString.length)];
    return linkString;
}

- (NSMutableAttributedString *)getFormattedString:(NSString *)string
{
    NSDictionary * attributes = [NSDictionary dictionaryWithObject:[UIFont fontWithName:FONT_MuseoSans300 size:13.5f] forKey:NSFontAttributeName];
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

#pragma mark - TapGesture

- (void)setupGesture
{
    UITapGestureRecognizer *tapOnTextView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(linkTapOnTextView:)];
    [self.textView addGestureRecognizer:tapOnTextView];
}

- (void)linkTapOnTextView:(UIGestureRecognizer *)gesture
{
    UITextView *textView = (UITextView *)gesture.view;
    NSLayoutManager *layoutManager = textView.layoutManager;
    CGPoint location = [gesture locationInView:textView];
    location.x -= textView.textContainerInset.left;
    location.y -= textView.textContainerInset.top;
    NSUInteger characterIndex = [layoutManager characterIndexForPoint:location inTextContainer:textView.textContainer fractionOfDistanceBetweenInsertionPoints:NULL];
    
    if (characterIndex < textView.textStorage.length) {
        NSRange range;

        NSDictionary *attributes = [textView.textStorage attributesAtIndex:characterIndex effectiveRange:&range];
        if ([attributes objectForKey:AUVCEmailKey]) {
            [self openEmailPage];
        } else if ([attributes objectForKey:AUVCFaceBookKey]) {
            [self openFaceBookPage];
        } else if ([attributes objectForKey:AUVCTwitterKey]) {
            [self openTwitterPage];
        }
    }
}

#pragma mark - MailComposer

- (void)openEmailPage
{
    if ([MFMailComposeViewController canSendMail]) {
        [PEMailControllerConfigurator configureMailControllerBackgroundColor:UIColorFromRGB(0x4B9DE1)];
        if ([self setupMailController]) {
            [self presentMailComposer];
        }
    } else {
        [self showAlertView];
    }
}

- (BOOL)setupMailController
{
    self.mailController = [[MFMailComposeViewController alloc] init];
    self.mailController.mailComposeDelegate = self;
    [self.mailController setSubject:@"Feedback"];
    [self.mailController setToRecipients:@[@"Scrubup@Allistechnology.com.au"]];
    [self.mailController setMessageBody:[self getMessageBody] isHTML:YES];
    return YES;
}

- (void)showAlertView
{
    UIAlertView *alerMail = [[UIAlertView alloc] initWithTitle:@"No mail accounts" message:@"Please setup your e-mail account through device settings." delegate:self cancelButtonTitle:@"Close" otherButtonTitles: nil];
    [alerMail show];
}

- (NSString *)getMessageBody
{
    return @"Feedback";
}

- (void)presentMailComposer
{
    UITabBarController *rootController = (UITabBarController *)[UIApplication sharedApplication].delegate.window.rootViewController;
    rootController.modalPresentationStyle = UIModalPresentationFullScreen;
#ifdef __IPHONE_8_0
    self.mailController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
#endif
    [self presentViewController:self.mailController animated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }];
}

#pragma mark - TapActions

- (void)openFaceBookPage
{
    NSURL *faceBookURL = [NSURL URLWithString:AUVCFacebookLink];
    if (![[UIApplication sharedApplication] openURL:faceBookURL]) {
        NSLog(@"%@%@",@"Failed to open url:",[faceBookURL description]);
    }
}

- (void)openTwitterPage
{
    NSURL *twitterURL = [NSURL URLWithString:AUVCTwitterLink];
    if (![[UIApplication sharedApplication] openURL:twitterURL]) {
        NSLog(@"%@%@",@"Failed to open url:",[twitterURL description]);
    }
}

#pragma mark - MailComposerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    if (result) {
        switch (result) {
            case MFMailComposeResultSent:
                NSLog(@"You sent the email.");
                break;
            case MFMailComposeResultSaved:
                NSLog(@"You saved a draft of this email");
                break;
            case MFMailComposeResultCancelled:
                NSLog(@"You cancelled sending this email.");
                break;
            case MFMailComposeResultFailed:
                NSLog(@"Mail failed:  An error occurred when trying to compose this email");
                break;
            default:
                NSLog(@"An error occurred when trying to compose this email");
                break;
        }
    }
    if (error) {
        NSLog(@"Error to send mail - %@", error.localizedDescription);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
