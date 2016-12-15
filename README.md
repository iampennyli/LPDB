# LPDB
##The Simple ORM Database Tools for iOS.

LPDB基本原理主要是使用iOS runtime特性动态获取类属性，并将类属性映射成SQLite表结构。使用框架提供的API查找数据库记录时会自动将查找的结果映射成OC对象。

###支持类型
LPDBManager支持下面的这些**属性**类型：

* Int, Long, Long Long, NSInteger, NSUInteger等各种整型
* Float, Double 浮点型
* NSString
* NSDate
* NSData
* UIImage
* UIColor
* NSNumber
* NSDictionary
* NSArray
* NSSet
* Kind of LPDBModel Class

###如何使用

#####创建表

需要持久化的对象只要继承**LPDBModel**即完成了数据库表的创建。

举个栗子

~~~objc
@interface Person : LPDBModel
@property (nonamatic, strong) NSString *name;
@property (nonamatic, assign) NSInteger age;
@property (nonamatic, assign) float height;
@property (nonamatic, strong) UIColor *skinColor;
@property (nonamatic, strong) Dog *dog;
@end

@interface Dog : LPDBModel
@property (nonamatic, strong) NSString *name;
@end
~~~

这里就自动创建了Person表以及Dog表

####保存数据
~~~objc
[[LPDBManager defaultManager] saveModels: @[dog1, dog2, ...]];
~~~

####删除数据

~~~objc
[[LPDBManager defaultManager] deleteModels: @[dog1, dog2, ...]];
~~~

####查找数据

从Person表中查找年龄大于18且名字叫张三的人，返回符合条件Person对象的集合

~~~objc
NSArray <Person *> results = [[LPDBManager defaultManager] findModels: [Person class] where: @"age > 18 and name == 'zhangsan'"];
~~~

####批量更新
将名字叫张三的人的年龄修改成28岁，返回是否修改成功

~~~objc
BOOL success = [[LPDBManager defaultManager] batchUpdateOfModel: [Person class] withParams: @{@"age" : @(28)} where: @"name = 'zhangsan'"];
~~~

####批量删除
从Person表中删除所有狗叫阿旺的人，并返回是否成功
~~~objc
BOOL success = [[LPDBManager defaultManager] batchDeleteOfModels: [Person class] where: @"dog == 'a-wang'"];
~~~

####根据条件统计记录数

统计姓张的人的数量

~~~objc
NSUInteger count = [[LPDBManager defaultManager] countOfModel: [Person class] where: @"name like 张%"];
~~~

####判断记录是否存在

数据库中是否存对象

~~~objc
BOOL exist = [[LPDBManager defaultManager] existModel: person];
~~~


###自定义数据库路径

LPDB提供默认数据库，但是同时也支持自定义数据库，你可以这样：

~~~objc
LPDBManager *otherManager = [[LPDBManager alloc] initWithDBPath: db_path];
~~~

每一个Manager维护一个数据库串行queue，去执行push进去的数据库操作，多个Manager实例互不影响。

###多线程安全

LPDB是多线程安全的，可以在任何线程随便调用。：）

###更多，未完待续