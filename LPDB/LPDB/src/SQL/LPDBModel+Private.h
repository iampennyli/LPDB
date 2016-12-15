//
//  LPDBModel+Private.h
//  mtt
//
//  Created by pennyli on 2016/11/1.
//  Copyright © 2016年 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBModel.h"


@protocol LPDBModel_Private_Protocol <NSObject>

/**
 * 标示是否是脏数据（需要save数据库）
 */
@property (atomic, assign) BOOL dirty;

@end

@interface LPDBModel() <LPDBModel_Private_Protocol>

@end




