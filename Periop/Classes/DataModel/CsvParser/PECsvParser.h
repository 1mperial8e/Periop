//
//  PECsvParser.h
//  Periop
//
//  Created by Kirill on 9/25/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PECsvParser : NSObject

- (void)parseCsv:(NSString*)csvMainFileName withCsvToolsFileName:(NSString*)csvToolsFileName withSpecName:(NSString*)specName;

@end
