//
//  UIDropDownList.h
//  DropDownList
//
//  Created by Stas Volskyi on 14.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol UIDropDownListDelegate;

@interface UIDropDownList : UIView

@property (strong, nonatomic) NSArray *items;

@property (weak, nonatomic) id<UIDropDownListDelegate> delegate;

@property (assign, nonatomic) BOOL enabled;

@property (weak, nonatomic) UILabel *titleLabel;

// default is UITableViewCellSeparatorStyleLine
@property (assign, nonatomic) UITableViewCellSeparatorStyle separatorStyle;

// default is dropDownListHeight
@property (assign, nonatomic) CGFloat itemHeight;

// default is Gray
@property (strong, nonatomic) UIColor *separateColor;

// default is YES
@property (assign, nonatomic) BOOL allowAnimations;

// default is 5
@property (assign, nonatomic) NSInteger numberOfItemsToDraw;

// default value of these properties is TitleLable values
@property (assign, nonatomic) NSTextAlignment itemLabelTextAlignment;
@property (strong, nonatomic) UIFont *itemLabelFont;
@property (strong, nonatomic) UIColor *itemLabelTextColor;
@property (strong, nonatomic) UIColor *itemBackColor;

@end

@protocol UIDropDownListDelegate <NSObject>

@optional

- (void)dropDownList:(UIDropDownList *)dropDownList didSelectItemAtIndex:(NSInteger)idx;
- (void)dropDownList:(UIDropDownList *)dropDownList willOpenWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds;
- (void)dropDownList:(UIDropDownList *)dropDownList willCloseWithAnimation:(CABasicAnimation *)animation bounds:(CGRect)bounds;

@end