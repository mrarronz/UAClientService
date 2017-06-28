//
//  UAUPnPController.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAControlDevice.h"
#import "UAUPnPInfoModel.h"

@protocol UAUPnpControllerDelegate <NSObject>

@required
/// 设置url的回调
- (void)dlnaSetAVTransportURLResponse;

/// 获取播放状态的回调
- (void)dlnaGetTransportInfoResponse:(UAUPnPTransportInfo *)info;

@optional

/// 播放的回调
- (void)dlnaPlayResponse;

/// 暂停的回调
- (void)dlnaPauseResponse;

/// 停止投屏的回调
- (void)dlnaStopResponse;

/// 跳转进度的回调
- (void)dlnaSeekResponse;

/// 播放上一个的回调
- (void)dlnaPreviousResponse;

/// 播放下一个的回调
- (void)dlnaNextResponse;

/// 设置音量的回调
- (void)dlnaSetVolumeResponse;

/// 设置下一个url的回调
- (void)dlnaSetNextAVTransportURLResponse;

/// 获取音频信息
- (void)dlnaGetVolumeResponse:(NSString *)volume;

/// 获取播放进度
- (void)dlnaGetPositionInfoResponse:(UAUPnPAVPositionInfo *)info;

/// 未定义的响应/错误
- (void)dlnaUndefinedResponse:(NSString *)xmlString;

@end

@interface UAUPnPController : NSObject

@property (nonatomic, strong) UAControlDevice *device;
@property (nonatomic, assign) id<UAUPnpControllerDelegate> delegate;

/**
 *  初始化并建立设备连接
 */
- (instancetype)initWithDevice:(UAControlDevice *)device;

/**
 * 设置投屏地址
 * @param url 视频url
 */
- (void)setAVTransportURL:(NSString *)url;

/**
 * 设置下一个播放地址
 * @param url 下一个视频url
 */
- (void)setNextAVTransportURL:(NSString *)url;

/**
 * 播放
 */
- (void)play;

/**
 * 暂停
 */
- (void)pause;

/**
 * 结束
 */
- (void)stop;

/**
 * 下一个
 */
- (void)next;

/**
 * 前一个
 */
- (void)previous;

/**
 * 跳转进度
 * @param relTime 进度时间(单位秒)
 */
- (void)seek:(float)relTime;

/**
 * 跳转至特定进度或视频
 * @param target 目标值，可以是 00:02:21 格式的进度或者整数的 TRACK_NR。
 * @param unit   REL_TIME（跳转到某个进度）或 TRACK_NR（跳转到某个视频）。
 */
- (void)seekToTarget:(NSString *)target unit:(NSString *)unit;

/**
 * 获取播放进度,可通过协议回调使用
 */
- (void)getPositionInfo;

/**
 * 获取播放状态,可通过协议回调使用
 */
- (void)getTransportInfo;

/**
 * 获取音频,可通过协议回调使用
 */
- (void)getVolume;

/**
 * 设置音频值
 * @param value 值—>整数
 */
- (void)setVolumeValue:(NSString *)value;

@end
