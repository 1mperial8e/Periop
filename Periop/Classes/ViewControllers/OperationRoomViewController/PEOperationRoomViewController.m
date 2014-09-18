//
//  PEOperationRoomViewController.m
//  Periop
//
//  Created by Kirill on 9/4/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEOperationRoomViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEMediaSelect.h"

@interface PEOperationRoomViewController () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITextView *operationTextView;
@property (weak, nonatomic) IBOutlet UILabel *stepsLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *operationWithPhotoButton;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@end

@implementation PEOperationRoomViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;

    [self.collectionView registerNib:[UINib nibWithNibName:@"PEOperationRoomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"OperationRoomViewCell"];
    
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    self.navigationBarLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    self.navigationBarLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel.numberOfLines = 0;
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operation Room"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:@"\nProcedureName"];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    self.navigationBarLabel.attributedText = stringForLabelTop;
    self.navigationBarLabel.backgroundColor = [UIColor clearColor];
    self.navigationBarLabel.textColor = [UIColor whiteColor];
    
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    self.pageController.numberOfPages = 10;
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}


#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PEOperationRoomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperationRoomViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor greenColor];
    self.pageController.currentPage = [indexPath row];
    return cell;
}

#pragma mark - IBActions

- (IBAction)photoButton:(id)sender {
    CGRect position = self.collectionView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

- (IBAction)albumPhoto:(id)sender {
    NSLog(@"albumPhoto from Op");
}

- (IBAction)cameraPhoto:(id)sender {
    NSLog(@"camera Photo from Op");
}

- (IBAction)tapOnView:(id)sender {
     NSLog(@"tap on View");
    [[self.view viewWithTag:35] removeFromSuperview];
}

@end
