//
//  PEEquipmentViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEEquipmentViewController.h"
#import "PEEquipmentCategoryTableViewCell.h"
#import "PEToolsDetailsViewController.h"
#import "PEAddNewToolViewController.h"


@interface PEEquipmentViewController () <UITableViewDataSource, UITableViewDelegate, PEEquipmentCategoryTableViewCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) UILabel * navigationBarLabel;

@property (strong, nonatomic) NSMutableSet *cellCurrentlyEditing;
@property (weak, nonatomic) IBOutlet UIButton *addNewButton;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;

@end

@implementation PEEquipmentViewController

#pragma mark - LifeCycle


- (void)viewDidLoad
{
    [super viewDidLoad];

    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    navigationLabel.text = @"Procedure Name";
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel = navigationLabel;
    
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Clear" style:UIBarButtonItemStyleBordered target:self action:@selector(clearAll:)];
    self.navigationItem.rightBarButtonItem = closeButton;
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEquipmentCategoryTableViewCell" bundle:nil] forCellReuseIdentifier:@"equipmentCell"];
    self.cellCurrentlyEditing = [NSMutableSet new];
    
    CAGradientLayer * buttonAddLayer = [CAGradientLayer layer];
    buttonAddLayer.frame = self.addNewButton.layer.bounds;
    NSArray * colorArrayProcedure = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:249/255.0 green:236/255.0 blue:254/255.0 alpha:1.0f].CGColor,(id)[UIColor colorWithRed:234/255.0 green:240/255.0 blue:254/255.0 alpha:1.0f].CGColor, nil];
    buttonAddLayer.colors = colorArrayProcedure;
    NSArray* location = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f], [NSNumber numberWithFloat:1.0f], nil];
    buttonAddLayer.locations = location;
    buttonAddLayer.cornerRadius = self.addNewButton.layer.cornerRadius;
    [self.addNewButton.layer addSublayer:buttonAddLayer];
    
    CAGradientLayer * sendMailLayer = [CAGradientLayer layer];
    sendMailLayer.frame = self.emailButton.layer.bounds;
    NSArray * colorArrayDoctors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:160/255.0 green:227/255.0 blue:205/255.0 alpha:1.0f].CGColor,(id)[UIColor colorWithRed:139/255.0 green:222/255.0 blue:205/255.0 alpha:1.0f].CGColor, nil];
    sendMailLayer.colors = colorArrayDoctors;
    sendMailLayer.locations = location;
    sendMailLayer.cornerRadius = self.emailButton.layer.cornerRadius;
    [self.emailButton.layer addSublayer:sendMailLayer];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void) viewWillDisappear:(BOOL)animated{
    [super   viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

#pragma mark - IBActions

- (IBAction)addNewButton:(id)sender {
    PEAddNewToolViewController * addNewTool = [[PEAddNewToolViewController alloc] initWithNibName:@"PEAddNewToolViewController" bundle:nil];
    [self.navigationController pushViewController:addNewTool animated:NO];
}

- (IBAction)eMailButton:(id)sender {
}

- (IBAction)clearAll:(id)sender {
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PEEquipmentCategoryTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"equipmentCell" forIndexPath:indexPath];
    if (!cell){
        cell = [[PEEquipmentCategoryTableViewCell alloc] init];
    }
    cell.equipmentNameLabel.text = [NSString stringWithFormat:@"Tool number %i", (int)[indexPath row]];
    
    cell.delegate = self;
    if ([self.cellCurrentlyEditing containsObject:indexPath]){
        [cell setCellSwiped];
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 7;
}

#pragma mark - UITableViewDelegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Equipment Category";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    PEToolsDetailsViewController * toolDetailsView = [[PEToolsDetailsViewController alloc] initWithNibName:@"PEToolsDetailsViewController" bundle:nil];
    [self.navigationController pushViewController:toolDetailsView animated:NO];
}

#pragma mark - PEEquipmentCategoryTableViewCellDelegate

- (void)buttonDeleteAction{
    NSLog(@"inside button action from delegate PEEquipmentCategoryTableViewCellDelegate");
}

- (void)cellDidSwipedIn:(UITableViewCell *)cell{
    [self.cellCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}

- (void)cellDidSwipedOut:(UITableViewCell *)cell{
    NSIndexPath * currentlyEditedIndexPath = [self.tableView indexPathForCell:cell];
    [self.cellCurrentlyEditing addObject:currentlyEditedIndexPath];
}

@end
