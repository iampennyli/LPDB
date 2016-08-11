//
//  Person.m
//  DBTest
//
//  Created by pennyli on 15/10/26.
//  Copyright © 2015年 pennyli. All rights reserved.
//

#import "Person.h"

@implementation Person
+ (NSString *)primaryKey
{
    return @"name1";
}

+ (NSArray <NSString *> *)indexedProperties
{
    return @[@"height,birthDay"];
}
@end
