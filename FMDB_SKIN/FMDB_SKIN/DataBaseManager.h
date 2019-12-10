//
//  DataBaseManager.h
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/9.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
NS_ASSUME_NONNULL_BEGIN

@interface DataBaseManager : NSObject

- (instancetype)initWithPath:(NSString*)path;
/**建表*/
- (BOOL)createTableWithName:(NSString*)tableName columns:(NSDictionary*)columnDic;
/**插入数据*/
- (BOOL)insertDataWithColumns:(NSDictionary*)columnDic toTable:(NSString*)tableName;
/**删除数据*/
- (void)deleteDataWithColumns:(NSDictionary*)columnDic fromTable:(NSString*)tableName;
/**查找数据*/
- (FMResultSet*)findDataFromTable:(NSString*)tableName;
- (FMResultSet*)findDataFromTable:(NSString *)tableName columnName:(NSString *)columnName;
- (FMResultSet*)findDataFromTable:(NSString*)tableName conditionColumnNmae:(NSString*)conditionColumnName condition:(NSString*)condition ;

/**更新数据*/
- (void)updateDataWithTable:(NSString*)tableName columns:(NSDictionary*)columnDic condition:(NSInteger)UID;
/**更新数据*/
- (BOOL)updateDataWithTable:(NSString *)tableName columns:(NSDictionary *)columnDic conditionName:(NSString*)conditionName condition:(NSString*)condition;
@end

NS_ASSUME_NONNULL_END
