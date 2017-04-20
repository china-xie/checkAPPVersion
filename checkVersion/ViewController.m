//
//  ViewController.m
//  checkVersion
//
//  Created by 谢纪伟 on 17/4/20.
//  Copyright © 2017年 cn.com.rockmobile. All rights reserved.
//

#import "ViewController.h"
#import "checkVersionManager.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [checkVersionManager  checkNewEditionWithAppID:@"1177904945" ctrl:self];
   
    [checkVersionManager checkNewEditionWithAppID:@"1177904945" CustomAlert:^(AppleStoreModel *appInfo) {
        
    }];//2种用法,自定义Alert
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
