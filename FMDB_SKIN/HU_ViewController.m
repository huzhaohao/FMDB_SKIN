//
//  HU_ViewController.m
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/9.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import "HU_ViewController.h"
#import "demoModel.h"
#import "demoModel2.h"
#import "NSObject+FMDB_SKIN.h"

@interface HU_ViewController ()

@end

@implementation HU_ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor orangeColor];
    [demoModel initFMDB];
    demoModel *obj = [[demoModel alloc] init];
    obj.bb =3;
    obj.gg = 2;
    obj.name = @"BBC2";
    obj.fff = [UIImage imageNamed:@"mogut"];
    [obj insertData];
    NSArray *array =  [obj findAllData];;
    NSLog(@"%@",array);
    for (demoModel *object in array) {
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(200, 100, 200, 200)];
        imgV.image = object.fff;
        [self.view addSubview:imgV];
        object.name =@"doubi";
        NSLog(@"UID = %ld",object.UID);
    }
    [demoModel2 initFMDB];
    demoModel2 *obj2 = [[demoModel2 alloc] init];
    obj2.name2 = @"BB";
    obj2.nameTir = @"xx";
    obj2.namea = @"3";
    [obj2 insertData];
    NSArray *array2 =  [obj2 findAllData];
    for (demoModel2 *object in array2) {
        [object deleteDate];
        NSLog(@"a = %@",obj2.namea);
    }
    NSLog(@"%@",array2);

}

@end
