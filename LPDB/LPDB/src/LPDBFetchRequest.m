//
//  LPDBFetchRequest.m
//  mtt
//
//  Created by pennyli on 8/27/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBFetchRequest.h"
#import "NSString-SQLiteColumnName.h"
#import "LPDBWhereCondition.h"

@implementation LPDBFetchRequest

- (instancetype)initWithModelName:(NSString *)modelName
{
    if (self = [super initWithModelName: modelName]) {
        _groupBy = nil;
        _count = -1;
        _offset = -1;
    }
    return self;
}

+ (instancetype)fetchRequestWithModelName:(NSString *)modelName
{
    LPDBFetchRequest *request = [[LPDBFetchRequest alloc] initWithModelName: modelName];
    return request;
}

- (NSString *)requestString
{
    if (_requestString.length == 0) {
        NSMutableString *whereString = [[NSMutableString alloc] init];
        if (self.whereCondition.count) {
            
            NSMutableArray *andConditions = [NSMutableArray array];
            NSMutableArray *orConditions = [NSMutableArray array];
            for (LPDBWhereCondition *c in self.whereCondition) {
                if (c.andCondition) {
                    [andConditions addObject: c];
                } else
                    [orConditions addObject: c];
            }
            
            NSMutableString *andQueryString = nil;
            if (andConditions.count) {
                andQueryString = [NSMutableString string];
                if (andConditions.count > 1) {
                    [andQueryString appendString: @"("];
                }
                for (NSInteger i = 0; i < andConditions.count; i++) {
                    LPDBWhereCondition *c = andConditions[i];
                    [andQueryString appendString: c.resultString];
                    if (i != andConditions.count - 1) {
                        [andQueryString appendString: @" and "];
                    } else {
                        if (andConditions.count > 1) {
                            [andQueryString appendString: @")"];
                        }
                    }
                }
            }
            
            NSMutableString *orQueryString = nil;
            if (orConditions.count) {
                if (andQueryString) {
                    orQueryString = [NSMutableString stringWithFormat:@"%@ and ", andQueryString];
                } else
                    orQueryString = [NSMutableString string];
                if (orConditions.count > 1) {
                    [orQueryString appendString: @"("];
                }
                for (NSInteger i = 0; i < orConditions.count; i++) {
                    LPDBWhereCondition *c = orConditions[i];
                    [orQueryString appendString: c.resultString];
                    if (i != orConditions.count - 1) {
                        [orQueryString appendString: @" or "];
                    } else {
                        if (orConditions.count > 1) {
                            [orQueryString appendString: @")"];
                        }
                    }
                }
            }
            
            if (orQueryString) {
                [whereString appendString:orQueryString];
            } else if (andQueryString) {
                [whereString appendString:andQueryString];
            }
        }
        
        NSString *groupByString = nil;
        if (_groupBy.length) {
            groupByString = [NSString stringWithFormat: @"group by %@", [_groupBy stringAsSQLColumnName]];
        }
        
        __block NSString *orderByString = nil;
        if (_orderProperties.count > 0) {
            orderByString = @"order by ";
            [_orderProperties enumerateObjectsUsingBlock:^(NSSortDescriptor * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx > 0) {
                    // 多字段排序需要使用,分开
                    orderByString = [orderByString stringByAppendingString:@","];
                }
            
                orderByString = [orderByString stringByAppendingString:[obj.key stringAsSQLColumnName]];
                if (obj.ascending) {
                    orderByString = [orderByString stringByAppendingString: @" ASC "];
                } else {
                    orderByString = [orderByString stringByAppendingString: @" DESC "];
                }
            }];
        }
        
        NSString *countString = nil;
        if (_count != -1 && _count > 0) {
            countString = [NSString stringWithFormat: @"limit %ld", (long)_count];
            
            if (_offset != -1 && _offset > 0) {
                countString = [NSString stringWithFormat:@"%@ offset %ld", countString, (long)_offset];
            }
        }
        
        NSMutableString *resultString = [[NSMutableString alloc] init];
        if (whereString.length) {
            [resultString appendFormat: @"where %@", whereString];
        }
        
        if (groupByString.length) {
            [resultString appendFormat: @" %@", groupByString];
        }
        
        if (orderByString.length) {
            [resultString appendFormat:@" %@", orderByString];
        }
        
        if (countString) {
            [resultString appendFormat: @" %@", countString];
        }
        
        _requestString = resultString;
    }
    return _requestString;
}
@end


