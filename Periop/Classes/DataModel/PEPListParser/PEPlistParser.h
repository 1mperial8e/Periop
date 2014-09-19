//
//  PEPlistParser.h
//  Periop
//
//  Created by Kirill on 9/17/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Specialisation.h"

@interface PEPlistParser : NSObject

typedef void(^SpecialisationParser)(Specialisation* specialisation);


- (void)parsePList:(NSString*)pListName specialisation:(SpecialisationParser)handler;

@end
