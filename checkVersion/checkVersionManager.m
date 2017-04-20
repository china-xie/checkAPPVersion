//
//  checkVersionManager.m
//  checkVersion
//
//  Created by 谢纪伟 on 17/4/20.
//  Copyright © 2017年 cn.com.rockmobile. All rights reserved.
//

#import "checkVersionManager.h"
#import "AppleStoreModel.h"
@interface checkVersionManager()
//本地info文件
@property (strong,nonatomic)NSDictionary *infoDict;

@end
@implementation checkVersionManager
#pragma mark - 懒加载
- (NSDictionary *)infoDict {
    if (!_infoDict) {
        _infoDict = [NSBundle mainBundle].infoDictionary;
    }
    return _infoDict;
}

#pragma mark - 单例
+ (instancetype)shareManager {
    static checkVersionManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

#pragma mark - API
+ (void)checkNewEditionWithAppID:(NSString *)appID ctrl:(UIViewController *)containCtrl {
    
    [[self shareManager] checkNewVersion:appID ctrl:containCtrl];
    
}

+(void)checkNewEditionWithAppID:(NSString *)appID CustomAlert:(checkVersionBlock)checkVersionBlock {
    [[self shareManager] getAppStoreVersion:appID sucess:^(AppleStoreModel *model) {
        if(checkVersionBlock)checkVersionBlock(model);
    }];
}

- (void)checkNewVersion:(NSString *)appID ctrl:(UIViewController *)containCtrl {
    [self getAppStoreVersion:appID sucess:^(AppleStoreModel *model) {
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"有新的版本(%@)",model.version] message:model.releaseNotes preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"立即升级" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self updateRightNow:model];
        }];
        UIAlertAction *delayAction = [UIAlertAction actionWithTitle:@"稍后再说" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *ignoreAction = [UIAlertAction actionWithTitle:@"忽略" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [self ignoreNewVersion:model.version];
        }];
        
        [alertController addAction:updateAction];
        [alertController addAction:delayAction];
        [alertController addAction:ignoreAction];
        [containCtrl presentViewController:alertController animated:YES completion:nil];
    }];
}

#pragma mark - 立即升级
- (void)updateRightNow:(AppleStoreModel *)model {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:model.trackViewUrl]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:model.trackViewUrl] options:@{} completionHandler:nil];
    }
    
}

#pragma mark - 忽略新版本
- (void)ignoreNewVersion:(NSString *)version {
    //保存忽略的版本号
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"ingoreVersion"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - 获取AppStore上的版本信息
- (void)getAppStoreVersion:(NSString *)appID sucess:(void(^)(AppleStoreModel *))update {
    
    [self getAppStoreInfo:appID success:^(NSDictionary *respDict) {
        NSInteger resultCount = [respDict[@"resultCount"] integerValue];
        if (resultCount == 1) {
            NSArray *results = respDict[@"results"];
            NSDictionary *appStoreInfo = [results firstObject];
            
            //字典转模型
            AppleStoreModel *model = [[AppleStoreModel alloc] init];
            [model setValuesForKeysWithDictionary:appStoreInfo];
            //是否提示更新
            BOOL result = [self isEqualEdition:model.version];
            if (result) {
                if(update)update(model);
            }
        } else {
#ifdef DEBUG
            NSLog(@"AppStore上面没有找到对应id的App");
#endif
        }
    }];
    
}

#pragma mark - 返回是否提示更新
-(BOOL)isEqualEdition:(NSString *)newEdition {
    NSString *ignoreVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"ingoreVersion"];
    if([self.infoDict[@"CFBundleShortVersionString"] compare:newEdition] == NSOrderedDescending || [self.infoDict[@"CFBundleShortVersionString"] compare:newEdition] == NSOrderedSame ||
       [ignoreVersion isEqualToString:newEdition]) {
        return NO;
    } else {
        return YES;
    }
}

#pragma mark - 获取AppStore的info信息
- (void)getAppStoreInfo:(NSString *)appID success:(void(^)(NSDictionary *))success {
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"https://itunes.apple.com/CN/lookup?id=%@",appID]];
    [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error == nil && data != nil && data.length > 0) {
                NSDictionary *respDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                if (success) {
                    success(respDict);
                }
            }
        });
    }] resume];
    
}

@end
