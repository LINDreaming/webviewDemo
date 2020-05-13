//
//  ViewController.m
//  webviewDemo
//
//  Created by 林喜(linxi ) on 2018/4/12.
//  Copyright © 2018年 林喜(linxi ). All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()


@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MARK: 使用webview交互请用次方法
/*    [self.view addSubview:self.webview];
  NSString *urlString = [NSString stringWithFormat:@"http://ck-static.yun.pingan.com/static/ci/share/projects/demo/debug.html"];
//    NSString *urlString = [NSString stringWithFormat:@"https://schep-mooc-stg.pingan.com.cn/schep-mooc/index/downloadapp?format=sancunxuetang"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15]];
    [self registerJeCallBackMethod];
 */
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
