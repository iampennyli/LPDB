//
//  LPDBRequest.m
//  mtt
//
//  Created by pennyli on 8/31/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBRequest.h"

@implementation LPDBRequest

- (instancetype)initWithModelName:(NSString *)modelName
{
    if (self = [super init]) {
        _whereCondition = nil;
        _modelName = modelName;
    }
    return self;
}

- (NSString *)modelName
{
    return _modelName;
}

@end
