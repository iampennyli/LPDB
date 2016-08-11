//
//  LPDBBatchUpdateRequest.h
//  mtt
//
//  Created by pennyli on 8/31/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBRequest.h"

@interface LPDBBatchUpdateRequest : LPDBRequest

// 需要批量更新的属性
@property (nonatomic, strong) NSArray *propertys;

// 需要批量更新属性的对应的值
@property (nonatomic, strong) NSArray *values;

+ (instancetype)batchUpdateRequestWithModelName:(NSString *)modelName;
@end
