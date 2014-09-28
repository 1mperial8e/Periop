//
//  PEButtonWithTouchBegan.m
//  Periop
//
//  Created by Kirill on 9/27/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEButtonWithTouchBegan.h"

@implementation PEButtonWithTouchBegan

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.nextResponder touchesEnded:touches withEvent:event];
}

@end
