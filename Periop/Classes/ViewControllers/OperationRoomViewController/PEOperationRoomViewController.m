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
    // Do any additional setup after loading the view from its nib.
    
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
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
    NSMutableAttributedString *stringForLabelTop = [[NSMutableAttributedString alloc] initWithString:@"Operation Room"];
    
    [stringForLabelTop addAttribute:NSFontAttributeName
                              value:[UIFont systemFontOfSize:16.0]
                              range:NSMakeRange(0, stringForLabelTop.length)];
    
    NSMutableAttributedString *stringForLabelBottom = [[NSMutableAttributedString alloc] initWithString:@"\nProcedureName"];
    [stringForLabelBottom addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10.0] range:NSMakeRange(0, stringForLabelBottom.length)];
    
    
    [stringForLabelTop appendAttributedString:stringForLabelBottom];
    navigationLabel.attributedText = stringForLabelTop;
    //background
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    self.navigationBarLabel = navigationLabel;
    
    //navigation backButton
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    //set q-ty of pageContoll dots
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



@end
