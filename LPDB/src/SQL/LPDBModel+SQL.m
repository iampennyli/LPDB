//
//  LPDBModel+SQL.m
//  mtt
//
//  Created by pennyli on 8/27/15.
//  Copyright (c) 2015 Tencent. All rights reserved.
//

#import "LPDBModel+SQL.h"
#import <objc/runtime.h>
#import "LPDBManager.h"
#import "NSObject-ClassName.h"
#import "NSString-SQLiteColumnName.h"
#import "NSString-SQLitePersistence.h"
#import "LPDBManager+Private.h"

#define isCollectionType(x) (isNSSetType(x) || isNSArrayType(x) || isNSDictionaryType(x))
#define isNSArrayType(x) ([x isEqualToString:@"NSArray"] || [x isEqualToString:@"NSMutableArray"])
#define isNSDictionaryType(x) ([x isEqualToString:@"NSDictionary"] || [x isEqualToString:@"NSMutableDictionary"])
#define isNSSetType(x) ([x isEqualToString:@"NSSet"] || [x isEqualToString:@"NSMutableSet"])

#define isIntegerType(x) ([x isEqualToString:@"i"] || [x isEqualToString:@"I"] || [x isEqualToString:@"l"] || [x isEqualToString:@"L"] || [x isEqualToString:@"q"] || [x isEqualToString:@"Q"] || [x isEqualToString:@"s"] || [x isEqualToString:@"S"] || [x isEqualToString:@"B"] )
#define isFloatType(x) ([x isEqualToString:@"f"] || [x isEqualToString:@"d"])
#define isStringType(x) ([x isEqualToString:@"c"] || [x isEqualToString:@"C"])

static const NSString *readWritePropsLock = @"readWritePropsLock";
static const NSString *readWriteTableCheckedLock = @"readWriteTableCheckedLock";
static const NSString *readWriteSQLCaches = @"readWriteSQLCaches";
static const NSString *readWriteTableName = @"readWriteTableName";

@interface LPDBModel()
// special property for watch propertys value changed
@property (nonatomic, assign) BOOL isPropertysValueChanged__;
@end

@implementation LPDBModel(SQL)

- (instancetype)init
{
    if (self = [super init]) {
        _dirty = NO;
        self.pk = -1;
        [self addObserver: self forKeyPath: @"isPropertysValueChanged__" options: 0 context: nil];
    }
    return self;
}

- (void)dealloc
{
    [self removeObserver: self forKeyPath: @"isPropertysValueChanged__"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{   
    if (!self.isPropertysValueChanged__) {
        _dirty = YES;
    }
}

+ (NSSet <NSString *> *)keyPathsForValuesAffectingIsPropertysValueChanged__
{
    NSArray *allPropertys = [[[self class] propertiesWithEncodedTypes] allKeys];
    NSArray *ingorePropertys = [[self class] ignoredProperties];
    NSMutableArray *tmpAllPropertys = [NSMutableArray arrayWithArray: allPropertys];
    [tmpAllPropertys removeObjectsInArray: ingorePropertys];
    
    return [NSSet setWithArray: tmpAllPropertys];
}

- (BOOL)isPropertysValueChanged__
{
    return objc_getAssociatedObject(self, @selector(setIsPropertysValueChanged__));
}

- (void)setIsPropertysValueChanged__:(BOOL)setIsPropertysValueChanged__
{
    if ([self isPropertysValueChanged__] != setIsPropertysValueChanged__) {
        objc_setAssociatedObject(self, @selector(setIsPropertysValueChanged__), @(setIsPropertysValueChanged__), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)dirty
{
    return _dirty;
}

- (void)setDirty:(BOOL)dirty
{
    _dirty = dirty;
}

#pragma mark - Private

+ (NSDictionary *)propertiesWithEncodedTypes
{
    // Recurse up the classes, but stop at NSObject. Each class only reports its own properties, not those inherited from its superclass
    
    static NSMutableDictionary *propsByClass = nil;
    
    @synchronized(readWritePropsLock) {
        if (propsByClass == nil)
            propsByClass = [[NSMutableDictionary alloc] init];
        if ([[propsByClass allKeys] containsObject:[self className]])
            return [NSMutableDictionary dictionaryWithDictionary:[propsByClass objectForKey:[self className]]];
    }

    
    NSMutableDictionary *theProps;
    
    if ([self superclass] != [NSObject class])
        theProps = (NSMutableDictionary *)[[self superclass] propertiesWithEncodedTypes];
    else
        theProps = [NSMutableDictionary dictionary];
    
    unsigned int outCount;
    
    objc_property_t *propList = class_copyPropertyList([self class], &outCount);
    int i;
    
    // Loop through properties and add declarations for the create
    for (i=0; i < outCount; i++)
    {
        objc_property_t oneProp = propList[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(oneProp)];
        if ([propName isEqualToString: @"isPropertysValueChanged__"]) {
            continue;
        }
        NSString *attrs = [NSString stringWithUTF8String: property_getAttributes(oneProp)];
        // Read only attributes are assumed to be derived or calculated
        // See http://developer.apple.com/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/chapter_8_section_3.html
        if ([attrs rangeOfString:@",R,"].location == NSNotFound)
        {
            NSArray *attrParts = [attrs componentsSeparatedByString:@","];
            if (attrParts != nil)
            {
                if ([attrParts count] > 0)
                {
                    NSString *propType = [[attrParts objectAtIndex:0] substringFromIndex:1];
                    [theProps setObject:propType forKey:propName];
                }
            }
        }
    }
    @synchronized(readWritePropsLock) {
        [propsByClass setValue: theProps forKey: [self className]];
    }
    
    free(propList);
    return [NSMutableDictionary dictionaryWithDictionary: theProps];
}

+ (BOOL)tableExists:(FMDatabase *)db
{
    BOOL exists = NO;
    NSString *query = [NSString stringWithFormat: @"SELECT count(*) FROM sqlite_master WHERE type='table' AND name='%@'", [self tableName]];
    FMResultSet *set = [db executeQuery: query];
    if ([set next]) {
        exists = [set intForColumn: @"count(*)"];
    }
    [set close];
    return exists;
}

+ (NSString *)tableName
{
    return [[self class] className];
}

+ (NSArray *)tableColumns:(FMDatabase *)db
{
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *set = [db executeQuery:[NSString stringWithFormat:@"PRAGMA table_info(%@)", [self tableName]]];
    if ([set next]) {
        while ([set next]) {
            [columns addObject:[set stringForColumn: @"name"]];
        }
    }
    [set close];
    return columns;
}

+ (void)_createIndexed:(FMDatabase *)db
{
    NSString *deleteIndexSql = [NSString stringWithFormat: @"drop index if exists %@_index", [self className]];
    BOOL success = [db executeUpdate: deleteIndexSql];
    assert(success);
    
    NSArray *indexedProperties = [[self class] indexedProperties];
    if (indexedProperties.count) {
        __block NSString *indexedStr = @"";
        [indexedProperties enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            indexedStr = [indexedStr stringByAppendingString: obj];
            if (idx < indexedProperties.count - 1) {
                indexedStr = [indexedStr stringByAppendingString: @", "];
            }
        }];
        NSString *indexedSql = [NSString stringWithFormat: @"create index if not exists %@_index on %@(%@)", [self className], [self className], indexedStr];
        BOOL success = [db executeUpdate: indexedSql];
        assert(success);
    }
}

#pragma mark - Table logic

+ (void)tableCheck:(FMDatabase *)db
{
    NSDictionary* props = [[self class] propertiesWithEncodedTypes];
    NSMutableArray *allProps = [NSMutableArray arrayWithArray:[props allKeys]];
    
    [allProps removeObject: [[self class] primaryKey]];
    
    if ([self tableExists: db]) {
        NSArray *columns = [self tableColumns: db];
        NSMutableArray *insertColumnsSQLs = [NSMutableArray array];
        for (NSString *oneProp in allProps) {
            NSString *propName = [oneProp stringAsSQLColumnName];
            if (![columns containsObject: propName]) { // if not include in table
                NSMutableString *insertColumnSQL = [NSMutableString stringWithFormat: @"alter table %@ add ", [self tableName]];
                NSString *propType = props[oneProp];
                if (isIntegerType(propType)) {
                    [insertColumnSQL appendFormat:@"%@ INTEGER", propName];
                }
                else if (isStringType(propType)) {
                    [insertColumnSQL appendFormat:@"%@ INTEGER", propName];
                }
                else if (isFloatType(propType)) {
                    [insertColumnSQL appendFormat:@"%@ REAL", propName];
                } else if ([propType hasPrefix:@"@"]) {
                    NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                    Class propClass = objc_lookUpClass([className UTF8String]);
                    if ([propClass isSubclassOfClass:[LPDBModel class]]) {
                        [insertColumnSQL appendFormat:@"%@ TEXT", propName];
                    } else if ([propClass canBeStoredInSQLite]) {
                        [insertColumnSQL appendFormat:@"%@ %@", propName, [propClass columnTypeForObjectStorage]];
                    }
                }
                [insertColumnsSQLs addObject: insertColumnSQL];
            }
        }
        if (insertColumnsSQLs.count) {
            for (NSString *insertColumnSQl in insertColumnsSQLs) {
                [db executeUpdate: insertColumnSQl];
            }
        }
        
    } else {
        NSMutableString *createSQL = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (", [self tableName]];
        NSString *primaryKey = [[self class] primaryKey];
        if (primaryKey.length) {
            if ([[props allKeys] containsObject: primaryKey]) {
                NSString *propColumnName = [primaryKey stringAsSQLColumnName];
                NSString *propType = [props objectForKey: primaryKey];
                if (isIntegerType(propType) || isStringType(propType)) {
                    if ([primaryKey isEqualToString: @"pk"]) {
                        [createSQL appendFormat: @"%@ INTEGER PRIMARY KEY AUTOINCREMENT", propColumnName];
                    } else
                        [createSQL appendFormat: @"%@ INTEGER PRIMARY KEY", propColumnName];
                } else if (isFloatType(propType)) {
                    [createSQL appendFormat: @"%@ REAL PRIMARY KEY", propColumnName];
                } else if ([propType hasPrefix: @"@"]) {
                    NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                    Class propClass = objc_lookUpClass([className UTF8String]);
                    if ([propClass isSubclassOfClass:[LPDBModel class]]) {
                        [createSQL appendFormat:@"%@ TEXT PRIMARY KEY", propColumnName];
                    } else if ([propClass canBeStoredInSQLite]) {
                        [createSQL appendFormat:@"%@ %@ PRIMARY KEY", propColumnName, [propClass columnTypeForObjectStorage]];
                    }
                }
            }
        }
        
        if (primaryKey.length) {
            [createSQL appendString: @", "];
        }
        
        NSInteger index = 0;
        for (NSString *oneProp in allProps) {
            NSString *propName = [oneProp stringAsSQLColumnName];
            NSString *propType = [props objectForKey:oneProp];
            
            if (isIntegerType(propType)) {
                [createSQL appendFormat:@"%@ INTEGER", propName];
            }
            else if (isStringType(propType)) {
                [createSQL appendFormat:@"%@ INTEGER", propName];
            }
            else if (isFloatType(propType)) {
                [createSQL appendFormat:@"%@ REAL", propName];
            } else if ([propType hasPrefix:@"@"]) {
                NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                Class propClass = objc_lookUpClass([className UTF8String]);
                if ([propClass isSubclassOfClass:[LPDBModel class]]) {
                    [createSQL appendFormat:@"%@ TEXT", propName];
                } else if ([propClass canBeStoredInSQLite]) {
                    [createSQL appendFormat:@"%@ %@", propName, [propClass columnTypeForObjectStorage]];
                }
            }
            index++;
            if (index != allProps.count) {
                [createSQL appendString: @", "];
            }
        }
        [createSQL appendString:@")"];
        
        BOOL success = [db executeUpdate: createSQL];
        assert(success);
    }
    
     [self _createIndexed: db];
}

- (BOOL)save:(FMDatabase *)db
{
    NSAssert(db != nil, @"db is nil");
    
    static NSMutableArray *checkedTables = nil;
    @synchronized(readWriteTableCheckedLock) {    
        if (checkedTables == nil) {
            checkedTables = [NSMutableArray array];
        }
    }
    BOOL contain = NO;
    @synchronized(readWriteTableCheckedLock) {
        contain = [checkedTables containsObject: [self className]];
        if (!contain) {
            [checkedTables addObject: [self className]];
        }
    }
    
    if (!contain) {
        [[self class] tableCheck: db];
    }
    
    if (_dirty) {
        _dirty = NO;
        
        NSDictionary *props = [[self class] propertiesWithEncodedTypes];
        NSString *primaryKey = [[self class] primaryKey];
        
        NSMutableArray *allPropNames = [NSMutableArray arrayWithArray:[props allKeys]];
        [allPropNames removeObject: primaryKey];
        [allPropNames removeObjectsInArray: [[self class] ignoredProperties]];
        
        BOOL isPk = [primaryKey isEqualToString: @"pk"];
        
        static NSMutableDictionary *sqlCaches = nil;
        NSMutableString *updateSQL = nil;
        NSMutableString *bindSQL = [NSMutableString string];
        NSString *cacheKey = [self className];
        if (isPk && self.pk == -1) {
            cacheKey = [NSString stringWithFormat: @"%@-pk", [self className]];
        }
        
        @synchronized(readWriteSQLCaches) {
            if (sqlCaches == nil)
                sqlCaches = [[NSMutableDictionary alloc] init];
            if ([[sqlCaches allKeys] containsObject:cacheKey])
                updateSQL = [sqlCaches objectForKey:cacheKey];
        }
        
        if (updateSQL == nil) {
            
            if (isPk && self.pk == -1) {
                updateSQL = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (", [[self class] tableName]];
            } else {
                updateSQL = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (%@, ", [[self class] tableName], [primaryKey stringAsSQLColumnName]];
                [bindSQL appendString: @"?, "];
            }
            
            NSInteger index = 0;
            
            for (NSString *propName in allPropNames) {
                NSString *propType = [props objectForKey: propName];
                NSString *className = @"";
                if ([propType hasPrefix: @"@"])
                    className = [propType substringWithRange: NSMakeRange(2, [propType length] - 3)];
                
                if (index++ == allPropNames.count - 1) {
                    [updateSQL appendFormat: @"%@", [propName stringAsSQLColumnName]];
                    [bindSQL appendString: @"?"];
                } else {
                    [updateSQL appendFormat: @"%@, ", [propName stringAsSQLColumnName]];
                    [bindSQL appendString: @"?, "];
                }
            }
            
            [updateSQL appendFormat:@") VALUES (%@)", bindSQL];
            
            @synchronized(readWriteSQLCaches) {
                [sqlCaches setObject: updateSQL forKey: cacheKey];
            }
        }
        
        
        NSMutableArray *models = [NSMutableArray array];
        NSMutableArray *values = [NSMutableArray array];
        
        if (!(isPk && self.pk == -1)) {
            if (primaryKey.length) {
                id obj = [self primaryKeyValue];
                [values addObject: obj];
                id theProperty = [self valueForKey: primaryKey];
                if ([theProperty isKindOfClass: [LPDBModel class]]) {
                    if ([(LPDBModel *)theProperty dirty])
                        [models addObject: theProperty];
                }
            }
        }

        for (NSString *propName in allPropNames) {
            
            NSString *propType = props[propName];
            id theProperty = [self valueForKey: propName];
            if (theProperty == nil) {
                [values addObject: [NSNull null]];
            } else {
                if ([propType hasPrefix: @"@"]) {
                    NSString *className = [propType substringWithRange: NSMakeRange(2, [propType length] - 3)];
                    Class propClass = objc_lookUpClass([className UTF8String]);
                    if ([propClass isSubclassOfClass: [LPDBModel class]]) {
                        [values addObject: [(LPDBModel *)theProperty primaryKeyValue]];
                        if ([(LPDBModel *)theProperty dirty])
                            [models addObject: theProperty];
                    } else if ([propClass shouldBeStoredInBlob]) {
                        NSData *data = [theProperty sqlBlobRepresentationOfSelf];
                        [values addObject: data];
                    } else {
                        [values addObject: [theProperty sqlColumnRepresentationOfSelf]];
                    }
                } else {
                    [values addObject: theProperty];
                }
            }
        }

        if (db) {
            for (LPDBModel *model in models)
                [model save: db];
            BOOL success = [db executeUpdate: updateSQL withArgumentsInArray: values];
            return success;
        }
    }
    return YES;
}

+ (void)clearTable:(FMDatabase *)db;
{
    [db executeUpdate: [NSString stringWithFormat: @"delete from %@", [self tableName]]];
}

- (BOOL)remove:(FMDatabase *)db
{
    NSString *deleteStr = nil;
    NSString *primaryKey = [[self class ]primaryKey];
    id value = [self valueForKey: primaryKey];
    
    if ([value respondsToSelector: @selector(sqlColumnRepresentationOfSelf)] ) {
        deleteStr = [NSString stringWithFormat: @"delete from %@ where %@='%@'", [[self class] tableName], primaryKey, [value sqlColumnRepresentationOfSelf]];
    } else {
        deleteStr = [NSString stringWithFormat: @"delete from %@ where %@=%@", [[self class] tableName], primaryKey, [value sqlBlobRepresentationOfSelf]];
    }
    return [[self class] deleteModels: deleteStr db: db];
}

+ (LPDBModel *)find:(id)primaryObj db:(FMDatabase *)db
{
    if (primaryObj == nil) {
        return nil;
    }

    NSString *queryString = nil;
    if ([primaryObj respondsToSelector: @selector(sqlColumnRepresentationOfSelf)]) {
        queryString = [NSString stringWithFormat: @"select * from %@ where %@='%@'", [[self class] tableName], [[self class] primaryKey], [primaryObj sqlColumnRepresentationOfSelf]];
    } else {
        queryString = [NSString stringWithFormat: @"select * from %@ where %@=%@", [[self class] tableName], [[self class] primaryKey], [primaryObj sqlBlobRepresentationOfSelf]];
    }
    return [[self findModels: queryString db: db] lastObject];
    
}

+ (NSArray *)findModels:(NSString *)sql db:(FMDatabase *)db
{
    NSMutableArray *result = [NSMutableArray array];
    FMResultSet *set = [db executeQuery: sql];
    while ([set next]) {
        LPDBModel *model = [self objectFromResultSet: set db: db];
        [result addObject: model];
    }
    [set close];
    
    return result;
}

+ (NSUInteger)countOfModels:(NSString *)sql db:(FMDatabase *)db
{
    NSUInteger count = [db longForQuery: sql];
    return count;
}

+ (BOOL)updateModels:(NSString *)sql withValues:(NSArray *)values db:(FMDatabase *)db
{
    return [db executeUpdate: sql withArgumentsInArray: values];
}

+ (BOOL)deleteModels:(NSString *)sql db:(FMDatabase *)db
{
    return [db executeUpdate: sql];
}

- (BOOL)exist:(FMDatabase *)db
{
    NSString *queryString = nil;
    id value = [self valueForKey: [[self class] primaryKey]];
    if ([value respondsToSelector: @selector(sqlColumnRepresentationOfSelf)]) {
        queryString = [NSString stringWithFormat: @"select count(*) from %@ where %@='%@'", [[self class] tableName], [[self class] primaryKey], [value sqlColumnRepresentationOfSelf]];
    } else {
        queryString = [NSString stringWithFormat: @"select count(*) from %@ where %@=%@", [[self class] tableName], [[self class] primaryKey], [value sqlBlobRepresentationOfSelf]];
    }
    NSUInteger count = [db longForQuery: queryString];
    return count > 0;
}

+ (LPDBModel *)objectFromResultSet:(FMResultSet *)rs db:(FMDatabase *)db
{
    NSDictionary *resultDict = [rs resultDictionary];
    NSDictionary *props = [[self class] propertiesWithEncodedTypes];
    NSArray *ignoredProperties = [[self class] ignoredProperties];
    NSArray *propNames = [props allKeys];
    LPDBModel *model = [[[self class] alloc] init];
    for (NSString *cloumName in [resultDict allKeys]) {
        NSString *propName = [cloumName stringAsPropertyString];
        if (![propNames containsObject: propName] || [ignoredProperties containsObject: propName]) {
            continue;
        }
        NSString *propType = props[propName];
        id thePorperty = resultDict[cloumName];
        if (thePorperty != [NSNull null]) {
            if ([propType hasPrefix: @"@"]) {
                NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                Class propClass = objc_lookUpClass([className UTF8String]);
                if ([propClass isSubclassOfClass: [LPDBModel class]]) {
                    id key = resultDict[cloumName];
                    id value = [propClass find: key db: db];
                    if (value != nil) {
                        [model setValue: value forKey: propName];
                    }
                } else if ([propClass shouldBeStoredInBlob]) {
                    id obj = [propClass objectWithSQLBlobRepresentation: thePorperty];
                    [model setValue: obj forKey: propName];
                } else {
                    id obj = [propClass objectWithSqlColumnRepresentation: thePorperty];
                    [model setValue: obj forKey: propName];
                }
            } else {
                [model setValue: thePorperty forKey: propName];
            }
        }
    }
    [model setDirty: NO];
    return model;
}

- (id)primaryKeyValue
{
    NSDictionary *props = [[self class] propertiesWithEncodedTypes];
    NSString *primaryKey = [[self class] primaryKey];
    if (primaryKey.length) {
        id theProperty = [self valueForKey: primaryKey];
        if (theProperty == nil) {
            return [NSNull null];
        } else {
            NSString *propType = props[primaryKey];
            if ([propType hasPrefix: @"@"]) {
                NSString *className = [propType substringWithRange:NSMakeRange(2, [propType length]-3)];
                Class propClass = objc_lookUpClass([className UTF8String]);
                if ([propClass isSubclassOfClass: [LPDBModel class]]) {
                    return [theProperty primaryKeyValue];
                } else if ([propClass shouldBeStoredInBlob]) {
                    id value = [theProperty sqlBlobRepresentationOfSelf];
                    if (value == nil) {
                        return [NSNull null];
                    } else return value;
                } else {
                    id value = [theProperty sqlColumnRepresentationOfSelf];
                    if (value == nil) {
                        return [NSNull null];
                    } else return value;
                }
            } else {
                return [self valueForKey: primaryKey];
            }

        }
    } else {
        
    }
    return [NSNull null];
}
@end
