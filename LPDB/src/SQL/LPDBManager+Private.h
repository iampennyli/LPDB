//
//  LPDBManager+Private.h
//  mtt
//
//  Created by pennyli on 8/27/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBManager.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"

@interface LPDBManager()
@property (nonatomic, strong) FMDatabaseQueue *queue;
@end
