//
//  LPDBModel.m
//  DBTest
//
//  Created by pennyli on 7/21/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import "LPDBModel.h"
#import "NSObject-ClassName.h"

@implementation LPDBModel

+ (NSString *)modelName
{
    return [[self class] className];
}

+ (NSString *)primaryKey
{
    return @"pk";
}

+ (NSArray <NSString *> *)ignoredProperties
{
    return nil;
}

+ (NSArray <NSString *> *)indexedProperties
{
    return nil;
}
@end




