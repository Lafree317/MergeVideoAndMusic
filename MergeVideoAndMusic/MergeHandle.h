//
//  MergeHandle.h
//  MergeVideoAndMusic
//
//  Created by lanou3g on 15/12/27.
//  Copyright © 2015年 huchunyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
typedef void(^SuccessBlock)(NSURL *url);
@interface MergeHandle : NSObject{
    SuccessBlock successblock;
}
// 单例
+ (MergeHandle *)sinlgeClass;
// 合成两个通道
- (void)merageWithVideoUrl:(NSURL *)videoUrl
                  MusicUrl:(NSURL *)musicUrl
               SucessBlock:(SuccessBlock )sucessBlock;
// 传入音乐和时间截取音频
- (void)shearMusicWithMusicUrl:(NSURL *)musicUrl
                     TimeRange:(CMTimeRange)timeRange
                   SucessBlock:(SuccessBlock )sucessBlock;
@end
