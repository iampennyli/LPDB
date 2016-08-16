//
//  NSDictionary-SQLitePersistence.m
//  DBTest
//
//  Created by pennyli on 15/10/30.
//  Copyright © 2015年 pennyli. All rights reserved.
//

#import "NSDictionary-SQLitePersistence.h"
#import "NSObject-SQLitePersistence.h"

#define kNSDictionaryArchiveKey @"NSDictionary"

@implementation NSDictionary(SQLitePersistence)

+ (id)objectWithSQLBlobRepresentation:(NSData *)data;
{
    if (data == nil || [data length] == 0)
        return nil;
    
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id ret = [unarchiver decodeObjectForKey: kNSDictionaryArchiveKey];
    [unarchiver finishDecoding];
    
    return ret;
}

- (NSData *)sqlBlobRepresentationOfSelf
{
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData: data];
    [archiver encodeObject: self forKey: kNSDictionaryArchiveKey];
    [archiver finishEncoding];
    return data;
}

+ (BOOL)canBeStoredInSQLite
{
    return YES;
}

+ (NSString *)columnTypeForObjectStorage
{
    return kSQLiteColumnTypeBlob;
}

+ (BOOL)shouldBeStoredInBlob
{
    return YES;
}

@end
