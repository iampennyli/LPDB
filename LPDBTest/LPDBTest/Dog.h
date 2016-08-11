//
//  Dog.h
//  DBTest
//
//  Created by 鹏 李 on 10/31/15.
//  Copyright © 2015 pennyli. All rights reserved.
//

#import <LPDB/LPDB.h>

@interface Dog : LPDBModel
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *dna;
@property (nonatomic, assign) NSInteger age;
@end
