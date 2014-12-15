//
//  PETermsAndCondition.m
//  ScrubUp
//
//  Created by Kirill on 12/15/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PETermsAndCondition.h"

static NSString *const TACCaptionMain = @"DEED OF AGREEMENT FOR “SCRUBUP” USAGE – USER TERMS AND CONDITIONS \n\n";
static NSString *const TACCaptionRecitals = @"RECITALS\n";
static NSString *const TACCAptionAgreed = @"\n\nIT IS AGREED\n";
static NSString *const TACDoubleEmptyString = @"\n\n";
static NSString *const TACEmptyString = @"\n";

static NSInteger const TACAlphabetCapitalisedASCIIStart = 65;
static NSInteger const TACAlphabetLowerCaseASCIIStart = 97;

@interface PETermsAndCondition()

@property (strong, nonatomic) NSArray *subLevelOneFormattedStrings;

@end

@implementation PETermsAndCondition

#pragma mark - Lifecycle

- (instancetype)init
{
    if (self = [super init]) {
        self.subLevelOneFormattedStrings = [self numberedSublevelsTextList];
    }
    return self;
}

#pragma mark - Public

- (NSMutableAttributedString *)generateTermsAndConditionFormattedText
{
    NSMutableAttributedString *mainCaption = [self getFormattedCaption:TACCaptionMain textAligment:NSTextAlignmentCenter];
    NSMutableAttributedString *recitalsCaption = [self getFormattedCaption:TACCaptionRecitals textAligment:NSTextAlignmentLeft];
    NSMutableAttributedString *agreedCaption = [self getFormattedCaption:TACCAptionAgreed textAligment:NSTextAlignmentLeft];
    
    [mainCaption appendAttributedString:[self generatePartOne]];
    [mainCaption appendAttributedString:recitalsCaption];
    [mainCaption appendAttributedString:[self generateAlphabeticListFromFile:@"TermsAndConditions_part2" asciiCode:TACAlphabetCapitalisedASCIIStart]];
    [mainCaption appendAttributedString:agreedCaption];
    [mainCaption appendAttributedString:[self generatePartThree]];

    return mainCaption;
}

#pragma mark - Private

#pragma mark - Formatting and Reading

- (NSMutableAttributedString *)getFormattedCaption:(NSString *)string textAligment:(NSTextAlignment)aligment
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = aligment;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans700 size:13.5f],
                                 NSParagraphStyleAttributeName : style};
    
    NSMutableAttributedString *formattedCaption = [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
    return formattedCaption;
}

- (NSMutableAttributedString *)getFormattedString:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans300 size:13.5f],
                                 NSParagraphStyleAttributeName : style};
    
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSString *)readTextPartFile:(NSString *)fileName
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"txt"];
    NSError *fileReadingError;
    NSString *fileContent = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&fileReadingError];
    if (fileReadingError) {
        NSLog(@"Cant read file - %@", fileReadingError.localizedDescription);
        fileContent = @"Cant read file";
    }
    return fileContent;
}

- (NSArray *)textToSentenses:(NSString *)inputText
{
    NSMutableArray *results = [NSMutableArray array];
    [inputText enumerateSubstringsInRange:NSMakeRange(0, inputText.length) options:NSStringEnumerationBySentences usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
        [results addObject:substring];
    }];
    return results;
}

- (NSMutableAttributedString *)formattSubLavelOneFromString:(NSString *)string
{
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentLeft;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: [UIFont fontWithName:FONT_MuseoSans300 size:13.5f],
                                 NSParagraphStyleAttributeName : style,
                                 NSUnderlineStyleAttributeName: @(NSUnderlineStyleSingle)};
    
    return [[NSMutableAttributedString alloc] initWithString:string attributes:attributes];
}

- (NSArray *)numberedSublevelsTextList
{
    NSArray *subLevelOneString = [self textToSentenses:[self readTextPartFile:@"TermsAndConditionsSubLevels1_part3"]];
    NSMutableArray *formattedSubLevelString = [[NSMutableArray alloc] init];
    for (int i = 0; i < subLevelOneString.count; i++) {
        NSMutableString *letterNumbering = [[NSString stringWithFormat:@"%i. \t", i+1] mutableCopy];
        [letterNumbering appendString:subLevelOneString[i]];
        NSMutableAttributedString *subLevel = [self formattSubLavelOneFromString:letterNumbering];
        [formattedSubLevelString addObject:subLevel];
    }
    return formattedSubLevelString;
}

- (NSMutableAttributedString *)romanNumberedListFromFile:(NSString *)fileName
{
    NSArray * romanCharacterSet = @[@"I.", @"II.", @"III.", @"IV.", @"V.", @"VI.", @"VII.", @"VIII.", @"IX.", @"X.", @"XI.", @"XII.", @"XIII.", @"XIV.", @"XV."];
    
    NSArray *subLevelOneString = [self textToSentenses:[self readTextPartFile:fileName]];
    NSMutableAttributedString *formattedSubLevelString = [[NSMutableAttributedString alloc] init];
    for (int i = 0; i < subLevelOneString.count; i++) {
        NSMutableString *letterNumbering = [[NSString stringWithFormat:@"\t%@\t", romanCharacterSet[i]] mutableCopy];
        [letterNumbering appendString:subLevelOneString[i]];
        NSMutableAttributedString *subLevel = [self getFormattedString:letterNumbering];
        [formattedSubLevelString appendAttributedString:subLevel];
    }
    return formattedSubLevelString;
}

- (NSMutableAttributedString *)sublLevelStringAtIndex:(NSInteger)stringIndex
{
    NSMutableAttributedString *requestedSubLevel = [[NSMutableAttributedString alloc] initWithString:TACDoubleEmptyString];
    [requestedSubLevel appendAttributedString:self.subLevelOneFormattedStrings[stringIndex]];
    return requestedSubLevel;
}

#pragma mark - PartsFormatting

- (NSMutableAttributedString *)generatePartOne
{
    NSMutableAttributedString *partOne = [self getFormattedString:[self readTextPartFile:@"TermsAndConditions_part1"]];
    NSRange boldedRange = NSMakeRange(71, 2);
    [partOne addAttribute: NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans700 size:13.5] range:boldedRange];
    boldedRange = NSMakeRange(82, 8);
    [partOne addAttribute: NSFontAttributeName value:[UIFont fontWithName:FONT_MuseoSans700 size:13.5] range:boldedRange];
    return partOne;
}

- (NSMutableAttributedString *)generateAlphabeticListFromFile:(NSString *)fileName asciiCode:(NSInteger)acsii
{
    NSString *partTwo = [self readTextPartFile:fileName];
    NSArray *sentenses = [self textToSentenses:partTwo];
    NSInteger asciiCode = acsii;
    NSMutableString *resultedString = [[NSMutableString alloc] init];
    for (NSString *string in sentenses) {
        NSMutableString *letterNumbering = [[NSString stringWithFormat:@"%c. \t", asciiCode] mutableCopy];
        [letterNumbering appendString:string];
        [resultedString appendString:letterNumbering];
        asciiCode++;
    }
    NSMutableAttributedString *formattedPartTwo = [self getFormattedString:resultedString];
    return formattedPartTwo;
}

- (NSMutableAttributedString *)generatePartThree
{
    NSMutableAttributedString *mainContent = [[NSMutableAttributedString alloc] initWithAttributedString:self.subLevelOneFormattedStrings[0]];
    
    [mainContent appendAttributedString:[self getFormattedString:@"a. \t In this Deed, unless the context requires otherwise, the following shall apply:\n"]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_1"]];
    [mainContent appendAttributedString:[self getFormattedString:@"\nb. \t In this Deed, unless the context requires otherwise, the following words mean:\n"]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_2"]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:1]];
    [mainContent appendAttributedString:[self getFormattedString:[self readTextPartFile:@"Part3_2_1"]]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_3" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:2]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_4" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:3]];
    [mainContent appendAttributedString:[self getFormattedString:@"\n\t a.	In consideration for the right to use the SUA, the User:\n\n"]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_5"]];
    [mainContent appendAttributedString:[self getFormattedString:@"\n\t b.	A breach of this clause on the part of the User gives AT an immediate right to terminate this Deed."]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:4]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_6_1" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_6_2"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_6_3" asciiCode:103]]; //from 'g'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:5]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_7_1" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_7_2"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_7_3" asciiCode:100]]; //from 'd'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:6]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_8" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:7]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_9_1" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_9_2"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_9_3" asciiCode:100]]; //from 'd'
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_9_4"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_9_5" asciiCode:101]]; //from 'e'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:8]];
    [mainContent appendAttributedString:[self getFormattedString:@"\nThe User expressly acknowledges and agrees that:\n"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_10_1" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_10_2"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_10_3" asciiCode:100]]; //from 'd'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:9]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_11" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:10]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_12" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:11]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_13" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:12]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_14" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:13]];
    [mainContent appendAttributedString:[self getFormattedString:[self readTextPartFile:@"Part3_15"]]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:14]];
    [mainContent appendAttributedString:[self getFormattedString:[self readTextPartFile:@"Part3_16"]]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:15]];
    [mainContent appendAttributedString:[self getFormattedString:@"\na.\tThis Deed is governed by the law of New South Wales and the Parties:\n"]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_17_1"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_17_2" asciiCode:98]]; //from 'b'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:16]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_18_1" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[[NSAttributedString alloc] initWithString:TACEmptyString]];
    [mainContent appendAttributedString:[self romanNumberedListFromFile:@"Part3_18_2"]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_18_3" asciiCode:101]]; //from 'e'
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:17]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_19" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:18]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_20" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:19]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_21" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:20]];
    [mainContent appendAttributedString:[self generateAlphabeticListFromFile:@"Part3_22" asciiCode:TACAlphabetLowerCaseASCIIStart]];
    [mainContent appendAttributedString:[self sublLevelStringAtIndex:21]];
    [mainContent appendAttributedString:[self getFormattedString:@"Part3_23"]];
    
    return mainContent;
}

@end
