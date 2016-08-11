//
//  LPDBRequest.h
//  mtt
//
//  Created by pennyli on 8/31/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBWhereCondition.h"

/**LPDBFetchRequest、LPDBBatchUpdateRequest、LPDBBatchDeleteRequest的基类*/

@interface LPDBRequest : NSObject {
    
    NSString *_requestString;
@private
    NSString *_modelName;
}
// 查询的条件，数组包含的对象为LPDBWhereCondition
@property (nonatomic, strong) NSArray <__kindof LPDBWhereCondition *> *whereCondition;

// 数据库模型名字
@property (readonly) NSString *modelName;

// 根据条件生成的SQL语句
@property (readonly) NSString *requestString;

- (instancetype)initWithModelName:(NSString *)modelName;
@end
