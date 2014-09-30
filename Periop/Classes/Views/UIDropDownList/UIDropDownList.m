//
//  UIDropDownList.m
//  DropDownList
//
//  Created by Stas Volskyi on 14.09.14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "UIDropDownList.h"

static CGFloat const DLAnimationDuration = 0.15f;

@interface UIDropDownList () <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) BOOL isOpened;
@property (strong, nonatomic) UITableView *tableView;
@property (assign, nonatomic) NSInteger selectedItem;

@end

@implementation UIDropDownList

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self createSelf];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self createSelf];
    }    
    return self;
}


- (void)drawRect:(CGRect)rect {
    if (!self.titleLabel.text.length) {
        self.titleLabel.text = (NSString *)self.items[self.selectedItem];
    }    
}

#pragma mark - Custom Accessors

- (void)setNumberOfItemsToDraw:(NSInteger)numberOfItemsToDraw
{
    _numberOfItemsToDraw = numberOfItemsToDraw;
    self.tableView.frame = CGRectMake(0, self.titleLabel.frame.size.height, self.frame.size.width, self.numberOfItemsToDraw * self.itemHeight);
}

- (void)setItemHeight:(CGFloat)itemHeight
{
    _itemHeight = itemHeight;
    self.tableView.frame = CGRectMake(0, self.titleLabel.frame.size.height, self.frame.size.width, self.numberOfItemsToDraw * self.itemHeight);
}

- (void)setSeparateColor:(UIColor *)separateColor
{
    _separateColor = separateColor;
    self.tableView.separatorColor = separateColor;
}

- (void)setItemBackColor:(UIColor *)itemBackColor
{
    _itemBackColor = itemBackColor;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)separatorStyle
{
    _separatorStyle = separatorStyle;
    self.tableView.separatorStyle = separatorStyle;
}

#pragma mark - Private

- (void)openList
{
    if (!self.items.count) {
        return;
    }
    
    [self.tableView reloadData];
    
    CABasicAnimation *boundsAnimation;
    CGRect bounds;
    
    if (!self.allowAnimations) {
        CGRect frame = self.frame;
        frame.size.height += self.tableView.frame.size.height;
        self.frame = frame;
    } else {
        boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.duration = DLAnimationDuration;
        boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        boundsAnimation.fromValue = [NSValue valueWithCGRect:self.bounds];
        bounds = self.bounds;
        bounds.size.height += self.tableView.frame.size.height;
        boundsAnimation.toValue = [NSValue valueWithCGRect:bounds];
        boundsAnimation.delegate = self;
        boundsAnimation.removedOnCompletion = NO;
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration = DLAnimationDuration;
        CGPoint position = self.layer.position;
        positionAnimation.fromValue = [NSValue valueWithCGPoint:self.layer.position];
        position.y = self.frame.origin.y + bounds.size.height / 2;
        positionAnimation.toValue = [NSValue valueWithCGPoint:position];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        positionAnimation.removedOnCompletion = YES;
        
        [self.layer addAnimation:boundsAnimation forKey:@"openList"];
        self.layer.bounds = bounds;
        [self.layer addAnimation:positionAnimation forKey:nil];
        self.layer.position = position;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownList:willOpenWithAnimation:bounds:)]) {
        [self.delegate dropDownList:self willOpenWithAnimation:boundsAnimation bounds:bounds];
    }
}

- (void)closeList
{
    CABasicAnimation *boundsAnimation;
    CGRect bounds;
    
    if (!self.allowAnimations) {
        CGRect frame = self.frame;
        frame.size.height = self.titleLabel.frame.size.height;
        self.frame = frame;
    } else {
        boundsAnimation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        boundsAnimation.duration = DLAnimationDuration;
        boundsAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        boundsAnimation.fromValue = [NSValue valueWithCGRect:self.bounds];
        bounds = self.bounds;
        bounds.size.height = self.titleLabel.frame.size.height;
        boundsAnimation.toValue = [NSValue valueWithCGRect:bounds];
        boundsAnimation.delegate = self;
        boundsAnimation.removedOnCompletion = NO;
        
        CABasicAnimation *positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
        positionAnimation.duration = DLAnimationDuration;
        CGPoint position = self.layer.position;
        positionAnimation.fromValue = [NSValue valueWithCGPoint:self.layer.position];
        position.y = self.frame.origin.y + self.titleLabel.frame.size.height / 2;
        positionAnimation.toValue = [NSValue valueWithCGPoint:position];
        positionAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        positionAnimation.removedOnCompletion = YES;
        
        [self.layer addAnimation:boundsAnimation forKey:@"closeList"];
        self.layer.bounds = bounds;
        [self.layer addAnimation:positionAnimation forKey:nil];
        self.layer.position = position;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownList:willOpenWithAnimation:bounds:)]) {
        [self.delegate dropDownList:self willCloseWithAnimation:boundsAnimation bounds:bounds];
    }
}

- (void)createSelf
{
    self.enabled = YES;
    self.allowAnimations = YES;
    self.itemHeight = self.itemHeight ? self.itemHeight : self.frame.size.height;
    self.separateColor = self.separateColor ? self.separateColor : [UIColor grayColor];
    self.isOpened = NO;
    self.selectedItem = 0;
    self.clipsToBounds = YES;
    self.numberOfItemsToDraw = 5;
    self.itemBackColor = [UIColor clearColor];
    
    self.backgroundColor = [UIColor clearColor];
    UILabel *title = [[UILabel alloc] initWithFrame:self.bounds];
    title.textColor = [UIColor colorWithRed:(10.0/255.0) green:(56.0/255.0) blue:(255.0/255.0) alpha:1.0];
    [self addSubview:title];
    title.userInteractionEnabled = YES;
    title.adjustsFontSizeToFitWidth = YES;
    title.textAlignment = NSTextAlignmentCenter;
    self.titleLabel = title;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.frame.size.width, self.numberOfItemsToDraw * self.itemHeight)];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.bounces = NO;
    self.tableView.delegate = (id)self;
    self.tableView.dataSource = (id)self;
    self.tableView.backgroundColor = [UIColor clearColor];
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
#warning iOS 8
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        //self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
    self.tableView.separatorColor = self.separateColor;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [self addSubview:self.tableView];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.enabled) {
        UITouch *touch = [touches anyObject];
        CGPoint touchLocation = [touch locationInView:self];
        
        if (CGRectContainsPoint(self.titleLabel.frame, touchLocation)) {
            if (self.isOpened) {
                self.isOpened = NO;
                [self closeList];
            } else {
                self.isOpened = YES;
                [self openList];
            }
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.font = self.itemLabelFont ? self.itemLabelFont : self.titleLabel.font;
    cell.textLabel.textColor = self.itemLabelTextColor ? self.itemLabelTextColor : self.titleLabel.textColor;
    cell.textLabel.textAlignment = self.itemLabelTextAlignment ? self.itemLabelTextAlignment : NSTextAlignmentCenter;
    cell.textLabel.text = (NSString *)self.items[indexPath.row];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = self.itemBackColor;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
#warning iOS 8
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        //cell.layoutMargins = UIEdgeInsetsZero;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.itemHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.isOpened = NO;
    self.titleLabel.text = (NSString *)self.items[indexPath.row];
    self.selectedItem = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(dropDownList:didSelectItemAtIndex:)]) {
        [self.delegate dropDownList:self didSelectItemAtIndex:indexPath.row];
    }
    [self closeList];
}

#pragma mark - AnimationsDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [self.layer animationForKey:@"closeList"]) {
        [self.layer removeAnimationForKey:@"closeList"];
    } else if (anim == [self.layer animationForKey:@"openList"]) {
        [self.layer removeAnimationForKey:@"openList"];
    }
}

@end
