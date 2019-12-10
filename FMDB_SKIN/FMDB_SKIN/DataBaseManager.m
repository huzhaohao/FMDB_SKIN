//
//  DataBaseManager.m
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/9.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import "DataBaseManager.h"

@implementation DataBaseManager
{
    FMDatabase* _database;
    NSLock* _lock;
}
- (instancetype)initWithPath:(NSString*)path {
    if (self = [super init]) {
        //打开数据库
        _database = [[FMDatabase alloc] initWithPath:path];
        BOOL ret = [_database open];
        if (!ret) {
            NSLog(@"数据库打开失败");
        }
        _lock = [[NSLock alloc] init];
    }
    return self;
}
/**建表*/
- (BOOL)createTableWithName:(NSString*)tableName columns:(NSDictionary*)columnDic {
    [_lock lock];
    NSString* sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(UID INTEGER PRIMARY KEY AUTOINCREMENT",tableName];
    for (NSString* columnName in columnDic) {
        sql = [sql stringByAppendingFormat:@",%@ %@",columnName,columnDic[columnName]];
    }
    sql = [sql stringByAppendingString:@");"];
    BOOL ret = [_database executeUpdate:sql];
    if (!ret) {
        NSLog(@"%@:建表失败",tableName);
    }
    for (NSString* columnName in columnDic) {
        if (![_database columnExists:columnName inTableWithName:tableName]){
            NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ %@",tableName,columnName,columnDic[columnName]];
           ret = [_database executeUpdate:alertStr];
        }
    }
    [_lock unlock];
    return YES;
}
/**插入数据*/
- (BOOL)insertDataWithColumns:(NSDictionary*)columnDic toTable:(NSString*)tableName {
    [_lock lock];
    NSString* columnName = [columnDic.allKeys componentsJoinedByString:@","];
    NSMutableArray* tempArray  = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < columnDic.allValues.count; i++) {
        [tempArray addObject:@"?"];
    }
    NSString* valueString = [tempArray componentsJoinedByString:@","];
    NSString* sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES(%@);",tableName,columnName,valueString];
    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:columnDic.allValues];
    if (!ret) {
        NSLog(@"向表:%@中插入数据失败",tableName);
    }
    [_lock unlock];
    return ret;
}

/**删除数据*/
- (void)deleteDataWithColumns:(NSDictionary*)columnDic fromTable:(NSString*)tableName {
    [_lock lock];
    BOOL isFirst = YES;
    NSString* sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
    for (NSString* key in columnDic) {
        if (isFirst) {
            sql = [sql stringByAppendingString:@" WHERE "];
            isFirst = NO;
        } else {
            sql = [sql stringByAppendingString:@" AND "];
        }
        sql = [sql stringByAppendingFormat:@"%@=?",key];
    }
    sql = [sql stringByAppendingString:@";"];
    BOOL ret = [_database executeUpdate:sql withArgumentsInArray:columnDic.allValues];
    if (!ret) {
        NSLog(@"从:%@表中删除数据失败",tableName);
    }
    [_lock unlock];
}

/**查找数据*/
- (FMResultSet*)findDataFromTable:(NSString*)tableName {
    [_lock lock];
    NSString* columnName =@"*";
    NSString* sql = [NSString stringWithFormat:@"SELECT %@ FROM %@;",columnName,tableName];
    FMResultSet* set = [_database executeQuery:sql];
    [_lock unlock];
    return set;
}
- (FMResultSet*)findDataFromTable:(NSString *)tableName columnName:(NSString *)columnName {
    [_lock lock];
    NSString* sql = [NSString stringWithFormat:@"SELECT %@ FROM %@",columnName,tableName];
    sql = [sql stringByAppendingString:@";"];
    FMResultSet* set = [_database executeQuery:sql];
    [_lock unlock];
    return set;
}
- (FMResultSet*)findDataFromTable:(NSString*)tableName conditionColumnNmae:(NSString*)conditionColumnName condition:(NSString*)condition {
    [_lock lock];
    NSString* columnName =@"*";
    NSString* sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ = '%@';",columnName,tableName,conditionColumnName,condition];
    FMResultSet* set = [_database executeQuery:sql];
    [_lock unlock];
    return set;
}

/**更新数据*/
- (void)updateDataWithTable:(NSString*)tableName columns:(NSDictionary*)columnDic condition:(NSInteger)UID {
    [_lock lock];
    NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET ",tableName];
    NSArray* tempArray = columnDic.allKeys;
    for (int a = 0 ; a < tempArray.count; a ++ ) {
        NSString* key = tempArray[a];
        if ( a < tempArray.count-1) {
            sql = [sql stringByAppendingFormat:@"%@ = '%@',",tempArray[a],columnDic[key]];
        } else {
            sql = [sql stringByAppendingFormat:@"%@ = '%@' ",tempArray[a],columnDic[key]];
        }
    }
    sql = [sql stringByAppendingFormat:@"WHERE UID = %ld",(long)UID];
    BOOL ret = [_database executeUpdate:sql];
    if (!ret) {
        NSLog(@"更新%@表中的数据失败",tableName);
    }
    [_lock unlock];
}
/**
 *  更新数据
 */
- (BOOL)updateDataWithTable:(NSString *)tableName columns:(NSDictionary *)columnDic conditionName:(NSString*)conditionName condition:(NSString*)condition{
    [_lock lock];
    NSString* sql = [NSString stringWithFormat:@"UPDATE %@ SET ",tableName];
    NSArray* tempArray = columnDic.allKeys;
    for (int a = 0 ; a < tempArray.count; a ++ ) {
        NSString* key = tempArray[a];
        if ( a < tempArray.count-1) {
            sql = [sql stringByAppendingFormat:@"%@ = '%@',",tempArray[a],columnDic[key]];
        } else {
            sql = [sql stringByAppendingFormat:@"%@ = '%@' ",tempArray[a],columnDic[key]];
        }
    }
    sql = [sql stringByAppendingFormat:@"WHERE %@ = '%@'",conditionName,condition];
    BOOL ret = [_database executeUpdate:sql];
    if (!ret) {
        NSLog(@"更新%@表中的数据失败",tableName);
    }
    [_lock unlock];
    return ret;
}

@end
