//
//  UAControlDevice.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

#import "UAServiceModel.h"
#import "UADefineHeader.h"

@interface UAControlDevice : NSObject

@property (nonatomic, strong) GCDAsyncSocket *socket;

// Common
@property (nonatomic, copy) NSString *deviceName;
@property (nonatomic, copy) NSString *hostName;
@property (nonatomic, assign) UADeviceType deviceType;

// Airplay
@property (nonatomic, assign) UInt16 port;
@property (nonatomic, copy) NSString *ip;
@property (nonatomic, assign) CGFloat imageQuality;

// DLNA
@property (nonatomic, copy) NSString *urlHeader;
@property (nonatomic, strong) UAServiceModel *avTransport;
@property (nonatomic, strong) UAServiceModel *renderingControl;
@property (nonatomic, strong) NSArray *deviceArray;

/**
 * 获取当前请求的类型
 */
+ (NSString *)typeWithTag:(long)tag;

/**
 * 发送内容地址
 */
- (void)sendContentWithURL:(NSString *)url;

/**
 * 发送内容并调整进度，跳转到指定的位置播放
 * @param progress 0~1之间
 */
- (void)sendContentWithURL:(NSString *)url progress:(float)progress;

/**
 * 发送图片
 */
- (void)sendImage:(UIImage *)image;

/**
 * 发送协商请求
 */
- (void)reverse;

/**
 * 暂停播放
 */
- (void)pause;

/**
 * 继续播放
 */
- (void)play;

/**
 * 停止播放
 */
- (void)stop;

/**
 * 跳转进度
 */
- (void)seekToSeconds:(float)seconds;

@end
