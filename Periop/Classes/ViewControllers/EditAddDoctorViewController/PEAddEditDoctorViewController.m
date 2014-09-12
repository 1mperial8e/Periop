//
//  PEAddEditDoctorViewController.m
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import "PEMediaSelect.h"
#import "PEAddEditDoctorViewController.h"
#import "PEEditAddDoctorTableViewCell.h"
#import "PEProceduresTableViewCell.h"

@interface PEAddEditDoctorViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) UILabel * navigationBarLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@end

@implementation PEAddEditDoctorViewController

#pragma mark - LifeCycle

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
    //add label
    CGPoint center = CGPointMake(self.navigationController.navigationBar.frame.size.width, self.navigationController.navigationBar.frame.size.height);
    UILabel * navigationLabel = [[UILabel alloc ] initWithFrame:CGRectMake(0, 0, center.x, center.y)];
    navigationLabel.backgroundColor = [UIColor clearColor];
    navigationLabel.textColor = [UIColor whiteColor];
    if (self.navigationLabelDescription && self.navigationLabelDescription.length>0){
        navigationLabel.text=self.navigationLabelDescription;
    }
    else{
        navigationLabel.text = @"Add Surgeon";
    }
    navigationLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationBarLabel = navigationLabel;
    
    //create button for menu
    UIBarButtonItem * saveButton = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(saveButton:)];
    //add button to navigation bar
    self.navigationItem.rightBarButtonItem=saveButton;
    //navigation backButton
    UIBarButtonItem * backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStyleBordered target:self action:nil];
    self.navigationItem.backBarButtonItem = backBarButtonItem;

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
 
    [self.tableView registerNib:[UINib nibWithNibName:@"PEEditAddDoctorTableViewCell" bundle:nil] forCellReuseIdentifier:@"tableViewCellWithCollection"];
    [self.tableView registerNib:[UINib nibWithNibName:@"PEProceduresTableViewCell" bundle:nil] forCellReuseIdentifier:@"proceduresCell"];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationBarLabel removeFromSuperview];
}

- (void) viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar addSubview:self.navigationBarLabel];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBActions

-(IBAction)saveButton :(id)sender{
    
}
- (IBAction)addPhoto:(id)sender {
    CGRect position = self.imageView.frame;
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



#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
- (IBAction)addPhotoFromCamera:(id)sender {
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row]==0 && indexPath.section ==0) {
        PEEditAddDoctorTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCellWithCollection" forIndexPath: indexPath];
        if (!cell){
            cell = [[PEEditAddDoctorTableViewCell alloc] init];
        }
        return cell;
    }
    else {
        PEProceduresTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"proceduresCell" forIndexPath: indexPath];
        if (!cell){
            cell = [[PEProceduresTableViewCell alloc] init];
        }
        return cell;
    }

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([indexPath row]==0 && indexPath.section ==0){
        return 128.0;
    }
    else {
        return 64.0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 3;
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return @"Procedures";
}





@end
