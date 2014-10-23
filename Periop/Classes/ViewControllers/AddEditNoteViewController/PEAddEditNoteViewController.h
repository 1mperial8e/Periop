//
//  PEAddEditNoteViewController.h
//  Periop
//
//  Created by Kirill on 9/5/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PEAddEditNoteViewController : UIViewController

@property (weak, nonatomic) IBOutlet NSString *timeToShow;
@property (weak, nonatomic) IBOutlet NSString *noteTextToShow;

@property (assign, nonatomic) BOOL isEditNote;

@end
