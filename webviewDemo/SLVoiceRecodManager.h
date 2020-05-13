//
//  SLVoiceRecodVC.h
//  webviewDemo
//
//  Created by 林喜(linxi ) on 2018/5/14.
//  Copyright © 2018年 林喜(linxi ). All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SLVoiceRecodManager : NSObject
+ (instancetype)shareManager;
- (void)startRecord;
- (NSString *)stopRecord;
- (NSString*)getVoiceBase64;
- (NSData *)getVoiceData;

@end
