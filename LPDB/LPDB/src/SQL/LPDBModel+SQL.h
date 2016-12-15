//
//  LPDBModel+SQL.h
//  mtt
//
//  Created by pennyli on 8/27/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBModel.h"
#import "FMDatabase.h"

@interface LPDBModel(SQL)

- (BOOL)save:(FMDatabase *)db;
- (BOOL)remove:(FMDatabase *)db;

+ (void)clearTable:(FMDatabase *)db;
- (BOOL)exist:(FMDatabase *)db;

+ (NSArray *)findModels:(NSString *)sql db:(FMDatabase *)db;
+ (NSUInteger)countOfModels:(NSString *)sql db:(FMDatabase *)db;
+ (BOOL)updateModels:(NSString *)sql withValues:(NSArray *)values db:(FMDatabase *)db;
+ (BOOL)deleteModels:(NSString *)sql db:(FMDatabase *)db;
@end
