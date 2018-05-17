//
//  SLVoiceRecodVC.h
//  webviewDemo
//
//  Created by 林喜(平安科技北京共享开发中心三村工程分组) on 2018/5/14.
//  Copyright © 2018年 林喜(平安科技北京共享开发中心三村工程分组). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVoiceRecodManager : NSObject
+ (instancetype)shareManager;
- (void)startRecord;
- (NSString *)stopRecord;
- (NSString*)getVoiceBase64;
- (NSData *)getVoiceData;

@end
