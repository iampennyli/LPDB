//
//  LPDBModel.h
//  DBTest
//
//  Created by pennyli on 7/21/15.
//  Copyright (c) 2015 Cocoamad. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CompilerCheckedKeyPaths.h"

/**
    在FMDB上简单封住了一层ORM，利用property映射技术实现可以动态创建，更新数据库。
    使用非常简单，只需要继承LPDBModel就可以了
 
    目前支持的属性有：
        - LPDBModel派生类
        - NSInteger
        - float，double
        - NSString
        - NSDate
        - NSData 
        - UIImage
        - UIColor
        - NSNumber
        - NSDictionary
        - NSArray
        - NSSet
        - 以及支持NSCoding的对象
 
        目前不支持的有：
        - Struct
        - Union
        - 指针等
 */

@interface LPDBModel : NSObject {
@private
    BOOL _dirty;
}

/**
 默认主键
 */
@property (nonatomic, assign) NSInteger pk;

+ (NSString *)modelName;

/**
    返回model对象映射表的主键，注意一旦创建不得修改！，如果不覆盖实现此方法，则默认使用pk作为自增长主键
 */
+ (NSString *)primaryKey;

/**
    返回不需要存储的属性字段
 */
+ (NSArray <NSString *> *)ignoredProperties;

/**
    需要索引的属性字段
 */
+ (NSArray <NSString *> *)indexedProperties;

@end


