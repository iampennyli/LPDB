//
//  LPDBWhereCondition.m
//  mtt
//
//  Created by pennyli on 9/1/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBWhereCondition.h"
#import "NSString-SQLiteColumnName.h"
#import "NSObject-SQLitePersistence.h"

@implementation LPDBWhereCondition
- (instancetype)initWithProperty:(NSString *)property Operator:(NSString *)operatorStr value:(id)value;
{
    if (self = [super init]) {
        _andCondition = YES;
        NSAssert(property != nil && operatorStr != nil && value != nil, @"LPDBWhereCondition must not nil");
        _property = property;
        _operatorStr = operatorStr;
        _value = value;
    }
    return self;
}

- (NSString *)resultString
{
    NSMutableString *ret = [NSMutableString string];
    if ([_value respondsToSelector: @selector(sqlColumnRepresentationOfSelf)]) {
        NSString *sqlValue = [_value sqlColumnRepresentationOfSelf];
        [ret appendString: [NSString stringWithFormat: @"%@%@'%@'", [_property stringAsSQLColumnName], _operatorStr, sqlValue]];
    } else {
        NSData *sqlValue = [_value sqlBlobRepresentationOfSelf];
        [ret appendString: [NSString stringWithFormat: @"%@%@%@", [_property stringAsSQLColumnName], _operatorStr, sqlValue]];
    }
    return ret;
}

@end
