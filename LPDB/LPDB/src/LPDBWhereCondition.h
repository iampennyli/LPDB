//
//  LPDBWhereCondition.h
//  mtt
//
//  Created by pennyli on 9/1/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LPDBWhereCondition : NSObject {
@private
    NSString *_property;
    NSString *_operatorStr;
    id _value;
}

// 是否是and条件, default YES
@property (nonatomic, assign) BOOL andCondition;

// 根据初始化字段合成的string, 比如"name=pennyli"
@property (nonatomic, readonly) NSString *resultString;

// 使用property和操作符以及value生成condition
- (instancetype)initWithProperty:(NSString *)property Operator:(NSString *)operatorStr value:(id)value;
@end