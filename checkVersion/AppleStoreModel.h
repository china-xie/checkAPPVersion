//
//  AppleStoreModel.h
//  checkVersion
//
//  Created by 谢纪伟 on 17/4/20.
//  Copyright © 2017年 cn.com.rockmobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppleStoreModel : NSObject
/**
 *  版本号
 */
@property(nonatomic,copy) NSString * version;

/**
 *  更新日志
 */
@property(nonatomic,copy)NSString *releaseNotes;

/**
 *  更新时间
 */
@property(nonatomic,copy)NSString *currentVersionReleaseDate;


/**
 *  AppStore地址
 */
@property(nonatomic,copy)NSString *trackViewUrl;
@end
