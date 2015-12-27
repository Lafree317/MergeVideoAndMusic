//
//  MergeHandle.m
//  MergeVideoAndMusic
//
//  Created by lanou3g on 15/12/27.
//  Copyright © 2015年 huchunyuan. All rights reserved.
//

#import "MergeHandle.h"
#import "MBProgressHUD+MJ.h"
@implementation MergeHandle

// 单例
+ (MergeHandle *)sinlgeClass{
    static MergeHandle *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MergeHandle alloc] init];
    });
    return manager;
}
// 合成两个通道
- (void)merageWithVideoUrl:(NSURL *)videoUrl
                  MusicUrl:(NSURL *)musicUrl
               SucessBlock:(SuccessBlock )sucessBlock{
    
    // 视频采集
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    // 音频采集
    AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicUrl options:nil];
    
    CMTimeRange timeRange = CMTimeRangeMake(kCMTimeZero, musicAsset.duration);
    
    // 创建可变的音视频组合
    AVMutableComposition *comosition = [AVMutableComposition composition];
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    // 视频采集通道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //  把采集轨道数据加入到可变轨道之中
    [videoTrack insertTimeRange:timeRange ofTrack:videoAssetTrack atTime:kCMTimeZero error:nil];
    
    
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频采集通道
    AVAssetTrack *audioAssetTrack = [[musicAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 加入合成轨道之中
    [audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    // 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetMediumQuality];
    // 输出类型
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    
    // 路径
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 最终合成输出路径
    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"merge.mp4"];
    // 添加合成路径
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            // 传回Url
            sucessBlock(outputFileUrl);
        });
    }];

}
// 传入音乐和时间截取音频
- (void)shearMusicWithMusicUrl:(NSURL *)musicUrl
                     TimeRange:(CMTimeRange)timeRange
                   SucessBlock:(SuccessBlock )sucessBlock{
    // 音频采集
    AVURLAsset *musicAsset = [[AVURLAsset alloc] initWithURL:musicUrl options:nil];
    // 创建可变的音视频组合
    AVMutableComposition *comosition = [AVMutableComposition composition];
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频采集通道
    AVAssetTrack *audioAssetTrack = [[musicAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 加入合成轨道之中
    [audioTrack insertTimeRange:timeRange ofTrack:audioAssetTrack atTime:kCMTimeZero error:nil];
    
    // 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetAppleM4A];
    
    // 输出类型
    assetExport.outputFileType = AVFileTypeAppleM4A;
    
    // 路径
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 最终合成输出路径
    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"shear.m4a"];

    // 添加合成路径
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            // 传回Url
            sucessBlock(outputFileUrl);
        });
    }];


}
@end
