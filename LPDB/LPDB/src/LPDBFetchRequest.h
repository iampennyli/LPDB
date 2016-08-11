//
//  LPDBFetchRequest.h
//  mtt
//
//  Created by pennyli on 8/27/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBRequest.h"

@interface LPDBFetchRequest : LPDBRequest

// 需要排序的字段
@property (nonatomic, strong) NSArray<NSSortDescriptor *>* orderProperties;

// 合计统计查询字段
@property (nonatomic, strong) NSString *groupBy;

// 查询的数量，必须大于0，默认查询结果数量无上限
@property (nonatomic, assign) NSInteger count;

// 从哪个位置开始查询，与count配合使用
@property (nonatomic, assign) NSInteger offset;

+ (instancetype)fetchRequestWithModelName:(NSString *)modelName;

@end


