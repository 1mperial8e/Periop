//
//  TLBlurEffect.h
//  Trill
//
//  Created by Stas Volskyi on 10.07.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface UIColor (ScrubUp)

+ (UIColor *)blurTintColor;

@end

@implementation UIColor (ScrubUp)

+ (UIColor *)blurTintColor
{
    return [UIColor colorWithRed:(255.0/255.0) green:(255.0/255.0) blue:(255.0/255.0) alpha:0.1];
}

@end

@interface PEBlurEffect : NSObject

+ (UIImage *)applyBlurWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor maskImage:(UIImage *)maskImage inputImage:(UIImage *)image;

@end
