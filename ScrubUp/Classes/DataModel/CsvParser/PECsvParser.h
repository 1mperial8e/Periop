//
//  PECsvParser.h
//  ScrubUp
//
//  Created by Kirill on 9/25/14.
//  Copyright (c) 2014 Thinkmobiles. All rights reserved.
//
@protocol PECsvParserDelegate <NSObject>

@required
- (void)newSpecialisationDidDownloaded;

@end

@interface PECsvParser : NSObject

@property (weak, nonatomic) id<PECsvParserDelegate> delegate;

- (void)parseCsvMainFile:(NSString *)csvMainFileName csvToolsFile:(NSString *)csvToolsFileName specName:(NSString *)specName;

@end
