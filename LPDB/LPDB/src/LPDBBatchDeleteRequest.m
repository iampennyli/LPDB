//
//  LPDBBatchDeleteRequest.m
//  mtt
//
//  Created by pennyli on 8/31/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBBatchDeleteRequest.h"

@implementation LPDBBatchDeleteRequest

+ (instancetype)batchDeleteRequestWithModelName:(NSString *)modelName
{
    LPDBBatchDeleteRequest *request = [[LPDBBatchDeleteRequest alloc] initWithModelName: modelName];
    return request;
}


- (NSString *)requestString
{
    NSMutableArray *andConditions = [NSMutableArray array];
    NSMutableArray *orConditions = [NSMutableArray array];
    for (LPDBWhereCondition *c in self.whereCondition) {
        if (c.andCondition) {
            [andConditions addObject: c];
        } else
            [orConditions addObject: c];
    }
    
    NSMutableString *andDeleteString = nil;
    if (andConditions.count) {
        andDeleteString = [NSMutableString string];
        if (andConditions.count > 1) {
            [andDeleteString appendString: @"("];
        }
        for (NSInteger i = 0; i < andConditions.count; i++) {
            LPDBWhereCondition *c = andConditions[i];
            [andDeleteString appendString: c.resultString];
            if (i != andConditions.count - 1) {
                [andDeleteString appendString: @" and "];
            } else {
                if (andConditions.count > 1) {
                    [andDeleteString appendString: @")"];
                }
            }
        }
    }
    
    NSMutableString *orDeleteString = nil;
    if (orConditions.count) {
        if (andDeleteString) {
             orDeleteString = [NSMutableString stringWithFormat:@"%@ and ", andDeleteString];
        } else
            orDeleteString = [NSMutableString string];
        if (orConditions.count > 1) {
            [orDeleteString appendString: @"("];
        }
        for (NSInteger i = 0; i < orConditions.count; i++) {
            LPDBWhereCondition *c = orConditions[i];
            [orDeleteString appendString: c.resultString];
            if (i != orConditions.count - 1) {
                [orDeleteString appendString: @" or "];
            } else {
                if (orConditions.count > 1) {
                    [orDeleteString appendString: @")"];
                }
            }
        }
    }
    
    if (orDeleteString) {
        return orDeleteString;
    } else
        return andDeleteString;
}
@end
