//
//  UIImage+ImageWithJPGFile.m
//  Periop
//
//  Created by Kirill on 10/2/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "UIImage+ImageWithJPGFile.h"

@implementation UIImage (ImageWithJPGFile)

+ (UIImage*)imageNamedJPGFile: (NSString*)imageNameInLocalBundle {
    
    NSBundle * bundle = [NSBundle mainBundle];
    NSString *path = [bundle pathForResource:imageNameInLocalBundle ofType:@"jpg"];
    UIImage * image = [UIImage imageWithContentsOfFile:path];
    return image;
}

@end
