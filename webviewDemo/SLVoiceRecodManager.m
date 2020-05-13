//
//  SLVoiceRecodVC.m
//  webviewDemo
//
//  Created by 林喜(linxi ) on 2018/5/14.
//  Copyright © 2018年 林喜(linxi ). All rights reserved.
//

#import "SLVoiceRecodManager.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include "lampFramwork/lame.h"

static SLVoiceRecodManager *manager = nil;
@interface SLVoiceRecodManager ()<AVAudioRecorderDelegate>
@property(nonatomic,strong)AVAudioRecorder *avRecorder;
@property(nonatomic,strong)AVAudioSession *avSession;
@property (nonatomic, strong) NSURL *recordFileUrl; //文件地址

@end

@implementation SLVoiceRecodManager

+ (instancetype)shareManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc]init];
    });
    return  manager;
}


- (void)startRecord{
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryRecord error:&sessionError];
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [session setActive:YES error:nil];
    }
    //录音文件保存路径
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *recordUrl = [path stringByAppendingString:@"/RRecord.wav"];
    //2.获取文件路径
    self.recordFileUrl = [NSURL URLWithString:recordUrl];
    
            NSMutableDictionary *setting = [NSMutableDictionary dictionary];
            //录音格式
            [setting setObject:@(kAudioFormatLinearPCM) forKey:AVFormatIDKey];
            //采样率，8000/11025/22050/44100/96000（影响音频的质量）,8000是电话采样率
            [setting setObject:@(44100) forKey:AVSampleRateKey];
            //通道 , 1/2
            [setting setObject:@(2) forKey:AVNumberOfChannelsKey];
            //采样点位数，分为8、16、24、32, 默认16
            [setting setObject:@(16) forKey:AVLinearPCMBitDepthKey];
            //是否使用浮点数采样
            [setting setObject:@(YES) forKey:AVLinearPCMIsFloatKey];
            // 录音质量
            [setting setObject:@(AVAudioQualityMax) forKey:AVEncoderAudioQualityKey];
    
    //设置参数
//    NSDictionary *recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
//                                   //采样率  8000/11025/22050/44100/96000（影响音频的质量）
//                                   [NSNumber numberWithFloat: 8000.0],AVSampleRateKey,
//                                   // 音频格式
//                                   [NSNumber numberWithInt: kAudioFormatLinearPCM],AVFormatIDKey,
//                                   //采样位数  8、16、24、32 默认为16
//                                   [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,
//                                   // 音频通道数 1 或 2
//                                   [NSNumber numberWithInt: 2], AVNumberOfChannelsKey,
//                                   //录音质量
//                                   [NSNumber numberWithInt:AVAudioQualityMax],AVEncoderAudioQualityKey,@(YES),AVLinearPCMIsFloatKey,
//                                   nil];

    _avRecorder = [[AVAudioRecorder alloc] initWithURL:[NSURL URLWithString:recordUrl] settings:setting error:nil];
    if (_avRecorder) {
        _avRecorder.meteringEnabled = YES;
        [_avRecorder prepareToRecord];
        [_avRecorder record];
    }
}
- (NSString *)stopRecord{
    AVAudioSession *session =[AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryAmbient error:&sessionError];
    if (session == nil) {
        NSLog(@"Error creating session: %@",[sessionError description]);
    }else{
        [session setActive:YES error:nil];
    }
    
    if ([self.avRecorder isRecording]) {
        [self.avRecorder stop];
      return [self transformCAFToMP3];
    }
    return @"";
    
}

- (NSString *)transformCAFToMP3 {
    NSString *fileName = [NSString stringWithFormat:@"/%@.mp3", @"voice"];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:fileName];
    NSLog(@"%@",filePath);
    NSURL* mp3FilePath = [NSURL URLWithString:filePath];
    @try {
        int read, write;
        FILE *pcm = fopen([[_recordFileUrl absoluteString] cStringUsingEncoding:1], "rb");   //source 被转换的音频文件位置
        fseek(pcm, 4*1024, SEEK_CUR);                                                   //skip file header
        FILE *mp3 = fopen([[mp3FilePath absoluteString] cStringUsingEncoding:1], "wb"); //output 输出生成的Mp3文件位置
        const int PCM_SIZE = 8192;
        const int MP3_SIZE = 8192;
        short int pcm_buffer[PCM_SIZE*2];
        unsigned char mp3_buffer[MP3_SIZE];
        
        lame_t lame = lame_init();
        lame_set_in_samplerate(lame, 8000.0);
        lame_set_VBR(lame, vbr_default);
        lame_init_params(lame);

        do {
            read = (int)fread(pcm_buffer, 2*sizeof(short int), PCM_SIZE, pcm);
            if (read == 0)
                write = lame_encode_flush(lame, mp3_buffer, MP3_SIZE);
            else
                write = lame_encode_buffer_interleaved(lame, pcm_buffer, read, mp3_buffer, MP3_SIZE);

            fwrite(mp3_buffer, write, 1, mp3);

        } while (read != 0);

        lame_close(lame);
        fclose(mp3);
        fclose(pcm);
    }
    @catch (NSException *exception) {
        NSLog(@"%@",[exception description]);
        return @"";
    }
    @finally {
        NSLog(@"MP3生成成功");
    NSString*base64Str = [self mp3ToBASE64WithPath:filePath];
        NSLog(@"base64Str== %@",base64Str);
        return base64Str;
        
    }
}

- (NSString *)mp3ToBASE64WithPath:(NSString *)path{
        NSData *mp3Data = [NSData dataWithContentsOfFile:path];
        NSString *encodedBase64Str =[mp3Data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
        return encodedBase64Str;
}

- (NSString *)getVoiceBase64{
    NSString *fileName = [NSString stringWithFormat:@"/%@.mp3", @"voice"];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:fileName];
    NSLog(@"%@",filePath);
 return [self mp3ToBASE64WithPath:filePath];
}

- (NSData *)getVoiceData{
    NSString *fileName = [NSString stringWithFormat:@"/%@.mp3", @"voice"];
    NSString *filePath = [[NSHomeDirectory() stringByAppendingFormat:@"/Documents/"] stringByAppendingPathComponent:fileName];
    NSData *mp3Data = [NSData dataWithContentsOfFile:filePath];
    return mp3Data;

}
@end
