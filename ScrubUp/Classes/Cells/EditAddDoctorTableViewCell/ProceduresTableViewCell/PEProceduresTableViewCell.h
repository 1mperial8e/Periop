//
//  PEProceduresTableViewCell.h
//  ScrubUp
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEProceduresTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *procedureName;
@property (weak, nonatomic) IBOutlet UIButton *checkButton;

@property (strong, nonatomic) NSString *procedureID;

@end
