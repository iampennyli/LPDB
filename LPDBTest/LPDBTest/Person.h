//
//  Person.h
//  DBTest
//
//  Created by pennyli on 15/10/26.
//  Copyright © 2015年 pennyli. All rights reserved.
//

#import <LPDB/LPDB.h>
#import "Dog.h"

@interface Person : LPDBModel
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) BOOL sex;
@property (nonatomic, strong) NSString *name1;
@property (nonatomic, assign) float height;
@property (nonatomic, strong) NSDate *birthDay;
@property (nonatomic, strong) NSData *stuff;
@property (nonatomic, strong) UIImage *faceImg;
@property (nonatomic, strong) UIColor *skinColor;

@property (nonatomic, strong) NSArray *nsarray;
@property (nonatomic, strong) NSMutableArray *mutableArray;

@property (nonatomic, strong) NSDictionary *nsdictionary;
@property (nonatomic, strong) NSSet *nsset;

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSString *value;

@property (nonatomic, strong) Dog *dog;
@end
