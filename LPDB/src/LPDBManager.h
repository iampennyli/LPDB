//
//  LPDBManager.h
//  DBTest
//
//  Created by pennyli on 7/21/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBModel.h"


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
