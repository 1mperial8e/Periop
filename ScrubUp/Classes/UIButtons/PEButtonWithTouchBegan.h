//
//  PEButtonWithTouchBegan.h
//  ScrubUp
//
//  Created by Kirill on 9/27/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEButtonWithTouchBegan : UIButton

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;

@end
