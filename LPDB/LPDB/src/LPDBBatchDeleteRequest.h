//
//  LPDBBatchDeleteRequest.h
//  mtt
//
//  Created by pennyli on 8/31/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPDBRequest.h"

@interface LPDBBatchDeleteRequest : LPDBRequest

+ (instancetype)batchDeleteRequestWithModelName:(NSString *)modelName;
@end
