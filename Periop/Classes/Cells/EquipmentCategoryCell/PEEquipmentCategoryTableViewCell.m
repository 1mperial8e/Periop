//
//  PEEquipmentCategoryTableViewCell.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEquipmentCategoryTableViewCell.h"


static CGFloat const kBounceValue = 20.0f;

@interface PEEquipmentCategoryTableViewCell() <UIGestureRecognizerDelegate>

//PEEquipmentCategoryTableViewCellDelegate properties
@property (strong, nonatomic) UIPanGestureRecognizer * panRecognizer;
@property (assign, nonatomic) CGPoint startPoint;
@property (assign, nonatomic) CGFloat startingRightLayoutConstraintConstant;
//constraint between left and right side of View in ContentView
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * contentViewRightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint * contentViewLeftConstraint;
@property (weak, nonatomic) IBOutlet UIButton *buttonDeleteOutlet;

@end

@implementation PEEquipmentCategoryTableViewCell

#pragma mark - LifeCycle

- (void)awakeFromNib
{
    //PEEquipmentCategoryTableViewCellDelegate
    [super awakeFromNib];
    self.panRecognizer= [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panThisCell:)];
    self.panRecognizer.delegate = self;
    [self.viewWithContent addGestureRecognizer:self.panRecognizer];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

//fixing issue with not remembeering of cell's state
//close all cells during flipping tableView
- (void)prepareForReuse{
    [super prepareForReuse];
    [self resetConstraintConstantsToZero:NO notifyDelegateDidClose:NO];
}


#pragma mark - IBActions

- (IBAction)checkButton:(id)sender {
}

- (IBAction)deleteButton:(id)sender {
    //PEEquipmentCategoryTableViewCellDelegate delegate usage
    [self.delegate buttonAction];
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate & panRecognizer

//recognize pan and update constaint
- (void)panThisCell: (UIPanGestureRecognizer*) recognizer {
    switch (recognizer.state) {
            
        case UIGestureRecognizerStateBegan: {
            self.startPoint = [recognizer translationInView:self.viewWithContent];
            //set starting points for moveable part
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
            //NSLog(@"pan began");
            break;
        }
            
        case UIGestureRecognizerStateChanged:{
            CGPoint currentPoint = [recognizer translationInView:self.viewWithContent];
            CGFloat delt = currentPoint.x - self.startPoint.x;
            //NSLog(@"pan moved %f", delt);
            BOOL panningLeft = NO;
            //check to what side you make panning
            if (currentPoint.x < self.startPoint.x){
                panningLeft = YES;
            }
            if (self.startingRightLayoutConstraintConstant ==0){
                //if yes - mean the cell is closed now
                if (!panningLeft){
                    CGFloat constant = MAX(-delt, 0);
                    //found how many user pan in cell
                    if (constant ==0){
                        //if zero - cell closed
                        [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
                    }
                    else {
                        //opening
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
                else{
                    //found total length of path
                    CGFloat constant = MIN(-delt, [self buttonTotalWidth]);
                    //if same like button width - here point to open cell
                    if (constant == [self buttonTotalWidth]){
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    }
                    else{
                        //if less - set constraints back
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            else {
                //The cell was at least partially open.
                //how much adjustment mad
                CGFloat adjustment = self.startingRightLayoutConstraintConstant - delt;
                if (!panningLeft) {
                    CGFloat constant = MAX(adjustment, 0); //if negative - cell is closed
                    if (constant == 0) { //closed cell
                        [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:NO];
                    } else {//otherwise - set constraint to the right constraint
                        self.contentViewRightConstraint.constant = constant;
                    }
                } else {
                    CGFloat constant = MIN(adjustment, [self buttonTotalWidth]); //if adj is higher  the user has swipped to far  past from catch point
                    if (constant == [self buttonTotalWidth]) { //cell is open
                        [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:NO];
                    } else {
                        self.contentViewRightConstraint.constant = constant;
                    }
                }
            }
            self.contentViewLeftConstraint.constant = -self.contentViewRightConstraint.constant;
            break;
        }
            
        case UIGestureRecognizerStateEnded:{
            //NSLog(@"PanEnded");
            if (self.startingRightLayoutConstraintConstant == 0) {
                //We were opening
                CGFloat halfOfButtonOne = CGRectGetWidth(self.buttonDeleteOutlet.frame) / 2;
                if (self.contentViewRightConstraint.constant >= halfOfButtonOne) {
                    //Open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Re-close
                    [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES ];
                }
            } else {
                //We were closing
                //if more than one button - add here frames of another button
                CGFloat buttonOne =
                    CGRectGetWidth(self.buttonDeleteOutlet.frame)/2;
                if (self.contentViewRightConstraint.constant >= buttonOne) {
                    //Re-open all the way
                    [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
                } else {
                    //Close
                    [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
                }
            }
            break;
        }
            
        case UIGestureRecognizerStateCancelled:{
           //NSLog(@"pan Canceled");
            if (self.startingRightLayoutConstraintConstant == 0) {
                //We were closed - reset everything to 0
                [self resetConstraintConstantsToZero:YES notifyDelegateDidClose:YES];
            } else {
                //We were open - reset to the open state
                [self setConstraintsToShowAllButtons:YES notifyDelegateDidOpen:YES];
            }
            break;
        }
            
        default:
            break;
    }
}
//modify this method to get required width
- (CGFloat) buttonTotalWidth{
    return CGRectGetWidth(self.frame) - CGRectGetWidth(self.buttonDeleteOutlet.frame)*3.2;
}

//reset constraint
- (void) resetConstraintConstantsToZero: (BOOL) animated notifyDelegateDidClose: (BOOL)endEditing{
    //part for configuring open/close state
    if (endEditing){
        [self.delegate cellDidClose:self];
    }

    if (self.startingRightLayoutConstraintConstant == 0 &&
        self.contentViewRightConstraint.constant == 0) {
        //Already all the way closed, no bounce necessary
        return;
    }
    
    self.contentViewRightConstraint.constant = -kBounceValue;
    self.contentViewLeftConstraint.constant = kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        self.contentViewRightConstraint.constant = 0;
        self.contentViewLeftConstraint.constant = 0;
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

//set constraint
- (void)setConstraintsToShowAllButtons : (BOOL) animated notifyDelegateDidOpen: (BOOL)notifyDelegate{
    //part for configuring open/close state
    if (notifyDelegate){
        [self.delegate cellDidOpen:self];
    }
    
    if (self.startingRightLayoutConstraintConstant == [self buttonTotalWidth] &&
        self.contentViewRightConstraint.constant == [self buttonTotalWidth]) {
        return;
    }
    //2
    self.contentViewLeftConstraint.constant = -[self buttonTotalWidth] - kBounceValue;
    self.contentViewRightConstraint.constant = [self buttonTotalWidth] + kBounceValue;
    
    [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
        //set exctly position for opened cell
        self.contentViewLeftConstraint.constant = -[self buttonTotalWidth];
        self.contentViewRightConstraint.constant = [self buttonTotalWidth];
        
        [self updateConstraintsIfNeeded:animated completion:^(BOOL finished) {
            //4
            self.startingRightLayoutConstraintConstant = self.contentViewRightConstraint.constant;
        }];
    }];
}

//method for animation
- (void) updateConstraintsIfNeeded:(BOOL)animated completion: (void(^)(BOOL finished))completion{
    float duration =0;
    if (animated){
        duration = 0.1;
    }
    //here can be putted appropriate duration and animation type
    [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //Lays out the subviews immediately.
        [self layoutIfNeeded];
    } completion:completion];
}


- (void)openCell{
    [self setConstraintsToShowAllButtons:NO notifyDelegateDidOpen:NO];
}

#pragma mark - UIGestureRecognizerDelegate
//for recognizing simo actions
- (BOOL) gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


@end
