//
//  LPDBManager.h
//  DBTest
//
//  Created by pennyli on 7/21/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBModel.h"
#import "LPDBWhereCondition.h"
#import "LPDBFetchRequest.h"
#import "LPDBBatchDeleteRequest.h"
#import "LPDBBatchUpdateRequest.h"


@interface LPDBManager : NSObject

@property (nonatomic, readonly) NSString *path;

/**
 the defualtu manager
 */
+ (LPDBManager *)defaultManager;

/**
 custom the manager
 */
- (instancetype)initWithDBPath:(NSString *)path;

/**
 remove all models in the specified model class
 */
- (void)clearTable:(Class)modelClass;

/**
 save and update models
 */
- (void)saveModels:(NSArray<__kindof LPDBModel *> *)models;

/**
 delete models
 */
- (void)deleteModels:(NSArray<__kindof LPDBModel *> *)models;

/**
 find model based on specified conditions; return all models if sql is nil;
 */
- (NSArray <__kindof LPDBModel *> *)findModels:(Class)modelClass where:(NSString *)sql,...;

/**
 return count of models based on specified conditions; return all models count if sql if nil;
 */
- (NSUInteger)countOfModel:(Class)modelClass where:(NSString *)sql,...;

/**
  batch update models with params in specified sql conditions; update all models if sql is nil;
 */
- (BOOL)batchUpdateOfModel:(Class)modelClass withParams:(NSDictionary <NSString *, id> *)paramDict where:(NSString *)sql,...;

/**
  batch delete modes based on sql conditions; if sql is nil will remove all models, such as -[clearTable:]
 */
- (BOOL)batchDeleteOfModels:(Class)modelClass where:(NSString *)sql,...;

/**
 if the model is exist in the table return YES, or return NO;
 **/
- (BOOL)existModel:(LPDBModel *)model;

@end

#pragma mark - will be deprecated. not command to use.

@interface LPDBManager (Deprecated)

/**
 查询接口根据LPDBFetchRequest条件查询满足条件的对象;
 即将废弃，请使用- (NSArray <LPDBModel *> *)findModels:(NSString *)modelName where:(NSString *)sql,...;替换
 */
- (NSArray *)executeFetchRequest:(LPDBFetchRequest *)request DEPRECATED_MSG_ATTRIBUTE("use +[findModels:where:]");

/**
 批量更新以及删除接口 支持批量更新以及删除，对应LPDBRequest为LPDBBatchUpdateRequest以及LPDBBatchDeleteRequest;
 即将废弃，请使用- (BOOL)batchUpdateOfModel:(NSString *)modelName withParams:(NSDictionary <NSString *, id> *)paramDict where:(NSString *)sql,...; 和
 - (BOOL)batchDeleteOfModels:(NSString *)modelName where:(NSString *)sql,...; 替换
 */
- (BOOL)executeUpdateRequest:(LPDBRequest *)request DEPRECATED_MSG_ATTRIBUTE("use +[batchUpdateOfModel:withParams:where:] or +[batchDeleteOfModels:where]");

/**
 返回request对应的记录条数;
 即将废弃，请使用- (NSUInteger)countOfModel:(NSString *)modelName where:(NSString *)sql,...;替换
 */
- (NSUInteger)countForFetchRequest:(LPDBFetchRequest *)request DEPRECATED_MSG_ATTRIBUTE("use +[countOfModel:where:]");
@end
