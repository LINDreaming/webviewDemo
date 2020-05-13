//
//  DBRecordViewController.m
//  webviewDemo
//
//  Created by linxi on 2020/5/12.
//  Copyright © 2020 林喜(linxi ). All rights reserved.
//

#import "DBRecordViewController.h"
#import "SLVoiceRecodManager.h"

@interface DBRecordViewController ()

@end

@implementation DBRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)startRecord:(id)sender {
    SLVoiceRecodManager *manager = [SLVoiceRecodManager shareManager];
    [manager startRecord];
}
- (IBAction)stopRecord:(id)sender {
    SLVoiceRecodManager *manager = [SLVoiceRecodManager shareManager];
    NSString *base64String = [manager stopRecord];
}


@end
