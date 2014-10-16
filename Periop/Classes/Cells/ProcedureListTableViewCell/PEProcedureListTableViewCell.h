//
//  PEProcedureListTableViewCell.h
//  Periop
//
//  Created by Kirill on 10/16/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@protocol PEProcedureListTableViewCellGestrudeDelegate  <NSObject>

@required

- (void)longPressRecognised:(UITableViewCell *)cell;

@end

@interface PEProcedureListTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelProcedureName;

@property (strong, nonatomic) id <PEProcedureListTableViewCellGestrudeDelegate> delegate;

@end
