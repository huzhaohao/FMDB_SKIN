//
//  AppDelegate.m
//  FMDB_SKIN
//
//  Created by huzhaohao on 2019/12/9.
//  Copyright © 2019 huzhaohao. All rights reserved.
//

#import "AppDelegate.h"
#import "HU_ViewController.h"
@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [HU_ViewController new];
    [self.window makeKeyAndVisible];
    return YES;
}




@end
