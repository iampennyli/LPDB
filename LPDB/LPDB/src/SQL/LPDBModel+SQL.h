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
#import "LPDBFetchRequest.h"

@interface LPDBModel(SQL)
- (BOOL)dirty;
- (void)setDirty:(BOOL)dirty;

- (BOOL)save:(FMDatabase *)db;
- (BOOL)remove:(FMDatabase *)db;

+ (NSArray *)query:(LPDBFetchRequest *)request db:(FMDatabase *)db;
+ (BOOL)update:(LPDBRequest *)request db:(FMDatabase *)db;
+ (NSUInteger)count:(LPDBFetchRequest *)request db:(FMDatabase *)db;

+ (void)clearTable:(FMDatabase *)db;
- (BOOL)exist:(FMDatabase *)db;

+ (NSArray *)findModels:(NSString *)sql db:(FMDatabase *)db;
+ (NSUInteger)countOfModels:(NSString *)sql db:(FMDatabase *)db;
+ (BOOL)updateModels:(NSString *)sql withValues:(NSArray *)values db:(FMDatabase *)db;
+ (BOOL)deleteModels:(NSString *)sql db:(FMDatabase *)db;
@end
