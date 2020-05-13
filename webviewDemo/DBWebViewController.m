//
//  DBWebViewController.m
//  webviewDemo
//
//  Created by linxi on 2020/5/12.
//  Copyright © 2020 林喜(平安科技北京共享开发中心三村工程分组). All rights reserved.
//

#import "DBWebViewController.h"
#import <WebKit/WebKit.h>
#import <JavaScriptCore/JavaScriptCore.h>
#import "SLVoiceRecodManager.h"
#import "WebViewJavascriptBridge.h"


@interface DBWebViewController ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>
@property(nonatomic,strong)WKWebView *webview;
@property(nonatomic,strong)WKWebViewConfiguration *config;
@property WebViewJavascriptBridge *bridge;


@end

@implementation DBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // MARK: 使用webview交互请用次方法
    [self.view addSubview:self.webview];
  NSString *urlString = [NSString stringWithFormat:@"http://ck-static.yun.pingan.com/static/ci/share/projects/demo/debug.html"];
//    NSString *urlString = [NSString stringWithFormat:@"https://schep-mooc-stg.pingan.com.cn/schep-mooc/index/downloadapp?format=sancunxuetang"];
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:15]];
    [self registerJeCallBackMethod];
    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //注册方法监听coordinatePara
    [_config.userContentController addScriptMessageHandler:self name:@"coordinatePara"];
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //注册方法监听coordinatePara
    [_config.userContentController removeScriptMessageHandlerForName:@"coordinatePara"];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
//    NSString *nameString = @"2018,4-12";
//    NSString *jsStr = [NSString stringWithFormat:@"getLogInfo('%@')",nameString];
//    [self.webview evaluateJavaScript:jsStr completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
//        NSLog(@"error == %@",error.description);
//    }];
    // 录音；
    [self.webview evaluateJavaScript:@"window.recordPara" completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
        NSLog(@"ret == %@",ret);
        if (error != nil) {
            NSLog(@"error Desc = %@",error.description);
        }
    }];
}

// 接收JS传递过来的参数，方法名称为'coordinatePara'
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    NSLog(@"收到JS消息 == %@",message.body);
    if ([message.name isEqualToString:@"coordinatePara"]) {
    }else if ([message.name isEqualToString:@"startRecord"]){
        SLVoiceRecodManager *manager = [SLVoiceRecodManager shareManager];
        [manager startRecord];
    }else if ([message.name isEqualToString:@"stopRecord"]){
        SLVoiceRecodManager *manager = [SLVoiceRecodManager shareManager];
       NSString *base64String = [manager stopRecord];
        [self.webview evaluateJavaScript:[NSString stringWithFormat: @"getRecordInfo('%@')",base64String]completionHandler:^(id _Nullable ret, NSError * _Nullable error) {
            if (error) {
                NSLog(@"errror == %@",error.description);
            }
        }];
    }
}


- (void)registerJeCallBackMethod{
    self.bridge = [WebViewJavascriptBridge bridgeForWebView:self.webview];
    [self.bridge setWebViewDelegate:self];
    NSString *base64String = [[SLVoiceRecodManager shareManager]getVoiceBase64];
    [self.bridge registerHandler:@"stopRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(base64String);
        NSLog(@"base64String: %@", base64String);
    }];
    [self.bridge registerHandler:@"startRecord" handler:^(id data, WVJBResponseCallback responseCallback) {
        responseCallback(@"startRecord");
    }];
}


- (WKWebViewConfiguration *)config{
    if (!_config) {
        _config = [[WKWebViewConfiguration alloc]init];
        _config.preferences = [[WKPreferences alloc]init];
        _config.preferences.minimumFontSize = 10;
        _config.preferences.javaScriptEnabled = YES;
    }
    return _config;
}
- (WKWebView *)webview{
    if (!_webview) {
        _webview = [[WKWebView alloc]initWithFrame:self.view.frame configuration:self.config];
        _webview.navigationDelegate = self;
        _webview.frame = self.view.frame;
        _webview.backgroundColor = [UIColor lightGrayColor];
    }
    return _webview;
}


@end
