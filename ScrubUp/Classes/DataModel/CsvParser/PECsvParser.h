//
//  PECsvParser.h
//  ScrubUp
//
//  Created by Kirill on 9/25/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

@interface PECsvParser : NSObject

- (void)parseCsvMainFile:(NSString *)csvMainFileName csvToolsFile:(NSString *)csvToolsFileName specName:(NSString *)specName;

@end
