//
//  PELabelConfiguration.m
//  ScrubUp
//
//  Created by Kirill on 11/20/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PELabelConfiguration.h"

static NSString *const LCMessage = @"For optimal display on the screen, please take or choose photo with portrait orientation";

@implementation PELabelConfiguration

+ (UILabel *)setInformationLabelOnView:(UIView *)parentView
{
    UILabel *informationLabel = [[UILabel alloc] initWithFrame:CGRectMake(parentView.bounds.origin.x, parentView.bounds.origin.y, parentView.bounds.size.width, 60)];
    informationLabel.font = [UIFont fontWithName:FONT_MuseoSans300 size:13.5f];
    informationLabel.text = LCMessage;
    informationLabel.textColor = [UIColor whiteColor];
    informationLabel.numberOfLines = 0;
    informationLabel.textAlignment = NSTextAlignmentCenter;
    return informationLabel;
}

@end
