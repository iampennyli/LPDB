//
//  NSArray-SQLitePersistence.h
//  DBTest
//
//  Created by pennyli on 15/10/30.
//  Copyright © 2015年 pennyli. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject-SQLitePersistence.h"

@interface NSArray(SQLitePersistence) <SQLitePersistence>
+ (id)objectWithSQLBlobRepresentation:(NSData *)data;
- (NSData *)sqlBlobRepresentationOfSelf;

+ (BOOL)canBeStoredInSQLite;
+ (NSString *)columnTypeForObjectStorage;
+ (BOOL)shouldBeStoredInBlob;
@end