//
//  Dog.m
//  DBTest
//
//  Created by 鹏 李 on 10/31/15.
//  Copyright © 2015 pennyli. All rights reserved.
//

#import "Dog.h"
#import <LPDB/LPDB.h>

@implementation Dog

+ (NSString *)primaryKey
{
    return KeyPathForSelf(dna);
}
@end
