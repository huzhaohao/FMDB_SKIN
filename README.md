# FMDB_SKIN

```
#import "NSObject+FMDB_SKIN.h"

[demoModel initFMDB];
 demoModel *obj = [[demoModel alloc] init];
 obj.name = @"BBC2";
 [obj insertData];
 NSArray *array =  [obj findAllData];;
 NSLog(@"%@",array);
 for (demoModel *object in array) {
     object.name =@"doubi";
     NSLog(@"UID = %ld",object.UID);
     [object updateData];
 }
 [demoModel2 initFMDB];
 demoModel2 *obj2 = [[demoModel2 alloc] init];
 obj2.name2 = @"BB";
 [obj2 insertData];
 NSArray *array2 =  [obj2 findAllData];;
 NSLog(@"%@",array2);
```



###### V1.0.0 版本内容更新
1. 新功能     aaaaaaaaa
2. 新功能     bbbbbbbbb
3. 新功能     ccccccccc
4. 新功能     ddddddddd
