//
//  PEToolsDetailsViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEToolsDetailsViewController.h"
#import "PEOperationRoomCollectionViewCell.h"
#import "PEAddNewToolViewController.h"
#import "PEMediaSelect.h"

@interface PEToolsDetailsViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *specificationlabel;
@property (weak, nonatomic) IBOutlet UILabel *quantityLabel;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControll;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) UILabel    * navigationBarLabel;

@end

@implementation PEToolsDetailsViewController


#pragma mark - Lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //Register a nib file for use in creating new collection view cells.
    [self.collectionView registerNib:[UINib nibWithNibName:@"PEOperationRoomCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"OperationRoomViewCell"];
    //dimensions of navigationbar
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    //add label to navigation Bar
    UILabel * navigationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    //set text aligment - center
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    //q-ty of lines - 0 - many lines allowed
    navigationLabel.numberOfLines = 0;
    //set text
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operation Name"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:@"\nProcedureName"];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    navigationLabel.attributedText = stringForLabelTop;
    self.navigationBarLabel = navigationLabel;
    //background
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    
    //create button for menu
    UIBarButtonItem * propButton = [[UIBarButtonItem alloc] initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(propButton:)];
    //add button to navigation bar
    self.navigationItem.rightBarButtonItem=propButton;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.pageControll.numberOfPages = 10;
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

- (IBAction)propButton:(id)sender {
    
}

- (IBAction)photoButton:(id)sender {
    CGRect position = self.collectionView.frame;
    NSArray * array = [[NSBundle mainBundle] loadNibNamed:@"PEMediaSelect" owner:self options:nil];
    PEMediaSelect * view = array[0];
    view.frame = position;
    view.tag = 35;
    [self.view addSubview:view];
}

#pragma mark - XIB Action

//methods from xib view
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




#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 10;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    PEOperationRoomCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"OperationRoomViewCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor redColor];
    self.pageControll.currentPage = [indexPath row];
    return cell;
}


@end
