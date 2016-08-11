//
//  UIColor-SQLitePersistentObject.m
//  KnitMinder
//
//  Created by Paul Mietz Egli on 12/28/08.
//  Copyright 2008 Fullpower. All rights reserved.
//

#import "UIColor-SQLitePersistentObject.h"

#define kUIColorArchiverKey @"UIColor"

@implementation UIColor(SQLitePersistence)
+ (id)objectWithSQLBlobRepresentation:(NSData *)data {
    if (data == nil || [data length] == 0)
        return nil;
  
    NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    id ret = [unarchiver decodeObjectForKey:kUIColorArchiverKey];
    [unarchiver finishDecoding];
  
    return ret;
}
- (NSData *)sqlBlobRepresentationOfSelf {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:kUIColorArchiverKey];
    [archiver finishEncoding];
    return data;
}
+ (BOOL)canBeStoredInSQLite {
  return YES;
}
+ (NSString *)columnTypeForObjectStorage {
  return kSQLiteColumnTypeBlob; 
}
+ (BOOL)shouldBeStoredInBlob {
  return YES;
}
@end
