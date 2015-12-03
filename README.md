#前言
####因为最近做项目有遇到音视频合成的需求,但是网上的教程某些地方总是写的很模糊,所以自己调研完成之后决定写一篇博客分享出来,供大家一起学习进步

####音视频主要是利用AVFoundation框架下的AVMutableComposition来合成音视频.
####在AVMutableComposition中传入两个数据流,一个是音频一个是视频,之后调用合成方法就可以了
---
#上代码
##storyBoard中拖入一个button,一个imageView
![这里写图片描述](http://img.blog.csdn.net/20151203134609345)
##为了效果好可以将IamgeView的背景色调为黑色

##然后在ViewController中添加以下代码
```
#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD+MJ.h"
@interface ViewController ()
/** 用于播放 */
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)mergeAction:(UIButton *)sender {
    [self merge];
}
// 混合音乐
- (void)merge{
    // mbp提示框
    [MBProgressHUD showMessage:@"正在处理中"];
    // 路径
    NSString *documents = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    // 声音来源
    NSURL *audioInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"五环之歌" ofType:@"mp3"]];
    // 视频来源
    NSURL *videoInputUrl = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"myPlayer" ofType:@"mp4"]];

    // 最终合成输出路径
    NSString *outPutFilePath = [documents stringByAppendingPathComponent:@"merge.mp4"];
    // 添加合成路径
    NSURL *outputFileUrl = [NSURL fileURLWithPath:outPutFilePath];
    // 时间起点
    CMTime nextClistartTime = kCMTimeZero;
    // 创建可变的音视频组合
    AVMutableComposition *comosition = [AVMutableComposition composition];
    
    
    // 视频采集
    AVURLAsset *videoAsset = [[AVURLAsset alloc] initWithURL:videoInputUrl options:nil];
    // 视频时间范围
    CMTimeRange videoTimeRange = CMTimeRangeMake(kCMTimeZero, videoAsset.duration);
    // 视频通道 枚举 kCMPersistentTrackID_Invalid = 0
    AVMutableCompositionTrack *videoTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    // 视频采集通道
    AVAssetTrack *videoAssetTrack = [[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject];
    //  把采集轨道数据加入到可变轨道之中
    [videoTrack insertTimeRange:videoTimeRange ofTrack:videoAssetTrack atTime:nextClistartTime error:nil];
    
    
   
    // 声音采集
    AVURLAsset *audioAsset = [[AVURLAsset alloc] initWithURL:audioInputUrl options:nil];
    // 因为视频短这里就直接用视频长度了,如果自动化需要自己写判断
    CMTimeRange audioTimeRange = videoTimeRange;
    // 音频通道
    AVMutableCompositionTrack *audioTrack = [comosition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    // 音频采集通道
    AVAssetTrack *audioAssetTrack = [[audioAsset tracksWithMediaType:AVMediaTypeAudio] firstObject];
    // 加入合成轨道之中
    [audioTrack insertTimeRange:audioTimeRange ofTrack:audioAssetTrack atTime:nextClistartTime error:nil];
    
    // 创建一个输出
    AVAssetExportSession *assetExport = [[AVAssetExportSession alloc] initWithAsset:comosition presetName:AVAssetExportPresetMediumQuality];
    // 输出类型
    assetExport.outputFileType = AVFileTypeQuickTimeMovie;
    // 输出地址
    assetExport.outputURL = outputFileUrl;
    // 优化
    assetExport.shouldOptimizeForNetworkUse = YES;
    // 合成完毕
    [assetExport exportAsynchronouslyWithCompletionHandler:^{
        // 回到主线程
        dispatch_async(dispatch_get_main_queue(), ^{
            // 调用播放方法
            [self playWithUrl:outputFileUrl];
        });
    }];
}

/** 播放方法 */
- (void)playWithUrl:(NSURL *)url{
    // 传入地址
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:url];
    // 播放器
    AVPlayer *player = [AVPlayer playerWithPlayerItem:playerItem];
    // 播放器layer
    AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.frame = self.imageView.frame;
    // 视频填充模式
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    // 添加到imageview的layer上
    [self.imageView.layer addSublayer:playerLayer];
    // 隐藏提示框 开始播放
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:@"合成完成"];
    // 播放
    [player play];
}
```
##MBP是一个第三方提示类,如果不关心这个功能可以删除这三行代码和头文件
```
// mbp提示框
    [MBProgressHUD showMessage:@"正在处理中"];
// 隐藏提示框 开始播放
    [MBProgressHUD hideHUD];
    [MBProgressHUD showSuccess:@"合成完成"];
```


#效果图
###因为是gif..请自己yy出Uber视频配上五环之歌(我感觉还挺配的)

![这里写图片描述](http://img.blog.csdn.net/20151203134052917)

##GitHub:https://github.com/Lafree317/MergeVideoAndMusic
---
本人还是一只小菜鸡,不过是一只热心肠的菜鸡,如果有需要帮助或者代码中有更好的建议的话可以发邮件到lafree317@163.com中,我们一起进步XD

