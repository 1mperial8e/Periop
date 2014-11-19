//
//  UIImage+ImageWithJPGFile.h
//  ScrubUp
//
//  Created by Kirill on 10/2/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface UIImage (ImageWithJPGFile)

+ (UIImage *)imageNamedFile:(NSString *)imageNameInLocalBundle;
+ (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize;

@end
