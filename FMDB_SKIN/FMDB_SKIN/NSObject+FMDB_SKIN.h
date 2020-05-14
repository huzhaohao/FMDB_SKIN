//
//  NSObject+FMDB_SKIN.h
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/10.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>
@interface NSObject (FMDB_SKIN)

@property (nonatomic)NSInteger UID; //数据ID

//类使用前需要初始化
+ (instancetype)initFMDB;
- (void)insertData;
- (void)deleteData;
- (void)updateData;
- (NSArray *)findAllData;

@end


