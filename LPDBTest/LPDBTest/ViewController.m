//
//  ViewController.m
//  LPDBTest
//
//  Created by pennyli on 15/11/6.
//  Copyright © 2015年 pennyli. All rights reserved.
//

#import "ViewController.h"
#import "Person.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self saveExample];
    
//    [self queryExample];
    
//    [self updateExample];
    
    [self deleteExample];
}

- (void)saveExample
{
    NSMutableArray *persons = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        Person *p = [[Person alloc] init];
        p.key = @"key";
        p.value = @"value";
        p.age = 20;
        p.name1 = [NSString stringWithFormat: @"%@", @(i)];
        [persons addObject: p];
    }
    
    [[LPDBManager defaultManager] saveModels: persons];
    
    NSMutableArray *dogs = [NSMutableArray array];
    for (NSInteger i = 0; i < 10; i++) {
        Dog *p = [[Dog alloc] init];
        p.dna = [NSString stringWithFormat: @"%ld", i];
        p.name = @"wangcai";
        [dogs addObject: p];
    }
    
    [[LPDBManager defaultManager] saveModels: dogs];
    
}

- (void)deleteExample
{
    // delete model
    BOOL success = [[LPDBManager defaultManager] batchDeleteOfModels: Dog.class where: @"name='%@'", @"wangcai"];
    assert(success);
    
    success = [[LPDBManager defaultManager] batchDeleteOfModels: Person.class where: @"name1=%@ and age=%@", @"1", @(20)];
    assert(success);
}

- (void)updateExample
{
    // update model
    BOOL success = [[LPDBManager defaultManager] batchUpdateOfModel: Person.class withParams: @{@"value" : @"hello", @"age" : @(10), @"birthDay" : [NSDate date]} where: nil];
    assert(success);
}

- (void)queryExample
{
    NSArray *persons = [[LPDBManager defaultManager] findModels: Person.class where: @"name1='%@'", @"1"];
    for (Person *p in persons) {
        NSLog(@"pk:%ld", p.pk);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
}

@end
