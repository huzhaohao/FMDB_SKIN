//
//  NSObject+FMDB_SKIN.m
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/10.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import "NSObject+FMDB_SKIN.h"
#import <UIKit/UIKit.h>
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
    for (NSString *key in array ) {
        NSString *type =  [self checkPropertyName:self propertyName:key];
        NSLog(@"%@ = %@",key,type);
        if ([type isEqualToString:@"UIImage"]) {
            NSString *tmep = [NSString stringWithFormat:@"varbinary(%ld)",(long)1024*1024*10];
            [dic setValue:tmep forKey:key];
//            [dic setValue:@"varbinary(100000)" forKey:object];
        } else {
            [dic setValue:@"varchar(100)" forKey:key];
        }

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
            NSString *type =  [self checkPropertyName:self propertyName:key];
            if ([type isEqualToString:@"UIImage"]) {
                NSData *value = [set dataForColumn:key];
                UIImage *img = [[UIImage alloc] initWithData:value];
                [dic setValue:img forKey:key];
            } else {
                NSString *value = [set stringForColumn:key];
                [dic setValue:value forKey:key];
                NSLog(@"%@ = %@",key,value);
            }

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

    NSString *temp = [properyName substringToIndex:1];
    NSString *temp2 = [properyName substringFromIndex:1];
    //首字母大写
    temp = temp.capitalizedString;
    properyName = [NSString stringWithFormat:@"set%@%@:",temp,temp2];
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
            NSString *type =  [self checkPropertyName:self propertyName:keyArray[i]];
            if ([type isEqualToString:@"UIImage"]) {
               UIImage *value = dictionary[keyArray[i]];
                //把value通过setter方法赋值给实体类的属性
                [self performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
            } else {
                //获取字典中key对应的value
                NSString * value = [NSString stringWithFormat:@"%@",dictionary[keyArray[i]]];
                //把value通过setter方法赋值给实体类的属性
                [self performSelectorOnMainThread:setSel withObject:value waitUntilDone:[NSThread isMainThread]];
            }

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

        NSString *type =  [self checkPropertyName:self propertyName:key];
        if ([type isEqualToString:@"UIImage"]) {
            //获取属性对应的value
            UIImage* value = [self valueForKey:key];
            if (value){
                NSData *data = UIImagePNGRepresentation(value);
                [props setObject:data forKey:key];
            }
        } else {
            //获取属性对应的value
            id value = [self valueForKey:key];
            if (value){
                [props setObject:value forKey:key];
            }
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
/**
  * 返回对象中属性的类型
  * @return NSString 返回属性的类型
 **/
- (NSString*)checkPropertyName:(id) obj propertyName:(NSString *)name {
    NSString* propertyType;
    unsigned int propertyCount;
    objc_property_t* properties = class_copyPropertyList([obj class], &propertyCount);
    for(int i=0;i<propertyCount;i++){
        objc_property_t property = properties[i];
        const char * property_attr = property_getAttributes(property);
        //属性名称
        const char* propertyName = property_getName(property);
        NSString* propertyNameStr = [NSString stringWithUTF8String:propertyName];
        if (property_attr[1] == '@') {
             //属性对应的类型名字
            char* typeEncoding = property_copyAttributeValue(property,"T");
            NSString* typeEncodingStr = [NSString stringWithUTF8String:typeEncoding];
            typeEncodingStr = [typeEncodingStr stringByReplacingOccurrencesOfString:@"@" withString:@""];
            typeEncodingStr = [typeEncodingStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            typeEncodingStr = [typeEncodingStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
            if ([name isEqualToString:propertyNameStr]) {
                propertyType = typeEncodingStr;
//                NSLog(@"property_data_type1 %@ =%@",propertyNameStr,propertyType);
                break;
            }
        } else {
            if ([name isEqualToString:propertyNameStr]) {
                char * realType = [self getPropertyRealType:property_attr];
                NSString *property_data_type = [NSString stringWithFormat:@"%s", realType];
                propertyType = property_data_type;
//                NSLog(@"property_data_type2 %@ =%@",propertyNameStr,property_data_type);
                 break;
             }
        }
    }
    free(properties);

    return propertyType;
}

- (char *)getPropertyRealType:(const char *)property_attr {
    char * type;
    char t = property_attr[1];
    char d[2] = {t,'\0'};
    if (strcmp(d, @encode(char)) == 0) {
        type = "char";
    } else if (strcmp( d, @encode(int)) == 0) {
        type = "int";
    } else if (strcmp( d, @encode(short)) == 0) {
        type = "short";
    } else if (strcmp( d, @encode(long)) == 0) {
        type = "long";
    } else if (strcmp( d, @encode(long long)) == 0) {
        type = "long long";
    } else if (strcmp( d, @encode(unsigned char)) == 0) {
        type = "unsigned char";
    } else if (strcmp( d, @encode(unsigned int)) == 0) {
        type = "unsigned int";
    } else if (strcmp( d, @encode(unsigned short)) == 0) {
        type = "unsigned short";
    } else if (strcmp( d, @encode(unsigned long)) == 0) {
        type = "unsigned long";
    } else if (strcmp( d, @encode(unsigned long long)) == 0) {
        type = "unsigned long long";
    } else if (strcmp( d, @encode(float)) == 0) {
        type = "float";
    } else if (strcmp( d, @encode(double)) == 0) {
        type = "double";
    } else if (strcmp( d, @encode(_Bool)) == 0 || strcmp( d, @encode(bool)) == 0) {
        type = "BOOL";
    } else if (strcmp( d, @encode(void)) == 0) {
        type = "void";
    } else if (strcmp( d, @encode(char *)) == 0) {
        type = "char *";
    } else if (strcmp( d, @encode(id)) == 0) {
        type = "id";
    } else if (strcmp( d, @encode(Class)) == 0) {
        type = "Class";
    } else if (strcmp( d, @encode(SEL)) == 0) {
        type = "SEL";
    } else {
        type = "";
    }
    return type;
}


@end
