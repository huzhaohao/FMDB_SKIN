//
//  NSObject+FMDB_SKIN.m
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/10.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import "NSObject+FMDB_SKIN.h"
#import "DataBaseManager.h"
/**表储存的位置*/
#define PATH [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cache2.db"]

@implementation NSObject (FMDB_SKIN)

-(void)setUID:(NSInteger)UID {
     objc_setAssociatedObject(self, @"UID", @(UID), OBJC_ASSOCIATION_RETAIN);
}
- (NSInteger)UID {
    return [objc_getAssociatedObject(self, @"UID") integerValue];
}

static DataBaseManager* manager;

- (instancetype)initFMDB_SKin{
     self = [self init];
    if (self) {
     [self creatDB];
    }
    return self;
}

+ (instancetype)initFMDB{
   id obj = [[self alloc] initFMDB_SKin];
    return  obj;
}

- (void)creatDB{
    if (manager == nil) {
        manager = [[DataBaseManager alloc] initWithPath:PATH];
        NSLog(@"%@",@"数据库创建");
    }
    [self createTable];
}

- (BOOL)createTable {
    NSString *name = NSStringFromClass([self class]);
    NSArray *array = [self getAllProperties];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    for (NSString *object in array ) {
        [dic setValue:@"varchar(100)" forKey:object];
    }
    BOOL ret = [manager createTableWithName:name columns:dic];
    if (ret) {
          NSLog(@"创建表成功");
    } else {
          NSLog(@"创建表失败");
    }
    return ret;
}
- (void)insertData{
    NSString *name = NSStringFromClass([self class]);
    NSDictionary *dic = [self getAllPropertiesAndValues];
    BOOL ret = [manager  insertDataWithColumns:dic toTable:name];
    if (ret) {
       NSLog(@"插入成功");
    } else {
       NSLog(@"插入失败");
    }
}
- (void)deleteDate {
    NSString *name = NSStringFromClass([self class]);
    NSDictionary *dic = [self getAllPropertiesAndValues];
    [manager deleteDataWithColumns:dic fromTable:name];
}
- (void)updateData {
    NSString *name = NSStringFromClass([self class]);
    NSDictionary *dic = [self getAllPropertiesAndValues];
    [manager updateDataWithTable:name columns:dic condition:self.UID];
}
- (NSArray *)findAllData {
    NSString *name = NSStringFromClass([self class]);
    FMResultSet *set =  [manager findDataFromTable:name];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSArray *arrayP = [self getAllProperties];
    while ([set next]) {
        NSObject *model = [[[self class] alloc] init];
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        for (NSString *key in arrayP) {
            NSString *value = [set stringForColumn:key];
            [dic setValue:value forKey:key];
            NSLog(@"%@ = %@",key,value);
        }
        NSString *value = [set stringForColumn:@"UID"];
        model.UID = [value integerValue];
        [model assignToPropertyWithDictionary:dic];
        [array addObject: model];
    }
    return array;
}

#pragma mark --通过字符串创建字符串的setter方法，并返回--
- (SEL)creatSetterWithPropertyName:(NSString *)properyName {
    //首字母大写
    properyName = properyName.capitalizedString;
    properyName = [NSString stringWithFormat:@"set%@:",properyName];
    return NSSelectorFromString(properyName);
}
#pragma mark --把字典中的value赋值给实体类的属性---
- (void)assignToPropertyWithDictionary:(NSDictionary *)dictionary {
    if (dictionary == nil){
        return ;
    }
    NSArray * keyArray = [dictionary allKeys];
    //循环遍历字典的key,动态生成实体类的setter方法，然后把字典的value通过setter方法赋值给实体类的属性
    for (int i = 0 ; i < keyArray.count ; i ++ ){
        //获取实体类的setter方法
        SEL setSel = [self creatSetterWithPropertyName:keyArray[i]];
        if ([self respondsToSelector:setSel]){
            //获取字典中key对应的value
            NSString * value = [NSString stringWithFormat:@"%@",dictionary[keyArray[i]]];
            //把value通过setter方法赋值给实体类的属性
            [self performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
        }
    }
}

#pragma mark --获取所有属性及对应的值---
-(NSDictionary *)getAllPropertiesAndValues{
    NSMutableDictionary *props = [NSMutableDictionary dictionary];
    unsigned int outCount;
    //属性的链表
    objc_property_t *properties =class_copyPropertyList([self class], &outCount);
    //遍历链表
    for (int i = 0; i<outCount; i++){
        objc_property_t property = properties[i];
        //获取属性字符串
        const char* propertyName =property_getName(property);
        //转换成NSString
        NSString *key = [NSString stringWithUTF8String:propertyName];
        //获取属性对应的value
        id value = [self valueForKey:key];
        if (value){
            [props setObject:value forKey:key];
        }
    }
    //释放结构体数组内存
    free(properties);
    return props;
}

#pragma mark --获取对象的所有属性--
- (NSArray *)getAllProperties {
    unsigned int count;
    //获取属性的链表
    objc_property_t *properties  =class_copyPropertyList([self class], &count);
    NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++) {
        objc_property_t property = properties[i];
        const char* propertyName =property_getName(property);
        [propertiesArray addObject: [NSString stringWithUTF8String:propertyName]];
    }
    free(properties);
    return propertiesArray;
}

@end
