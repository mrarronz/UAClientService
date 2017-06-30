//
//  UAControlManager.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UADefineHeader.h"
#import "UAControlDevice.h"
#import "UAUPnPController.h"

@class UAControlManager;

@protocol UAControlManagerDelegate <NSObject>

@optional
- (void)manager:(UAControlManager *)manager didFindDevice:(UAControlDevice *)device;
- (void)manager:(UAControlManager *)manager didConnectToDevice:(UAControlDevice *)device;
- (void)manager:(UAControlManager *)manager didStopSearchingWithServiceCount:(NSInteger)count;
- (void)manager:(UAControlManager *)manager didCompleteActionWithTag:(UAAirplayActionType)tag;

@end

@interface UAControlManager : NSObject

@property (nonatomic, strong) NSNetServiceBrowser *serviceBrowser;
@property (nonatomic, strong) UAUPnPController *dlnaController;
@property (nonatomic, strong) UAControlDevice *connectedDevice;

@property (nonatomic, strong) NSMutableArray *foundServices;
@property (nonatomic, assign) BOOL autoConnect;
@property (nonatomic, assign) BOOL isPlayPaused;
@property (nonatomic, assign) UAConnectionType connectType;
@property (nonatomic, assign) id<UAControlManagerDelegate> delegate;

+ (UAControlManager *)sharedManager;

/**
 * 开始搜索设备，30秒后停止搜索
 */
- (void)startSearching;

/**
 * 停止搜索
 */
- (void)stopSearching;

/**
 * 连接AirPlay设备
 */
- (void)connectAirplayDevice:(UAControlDevice *)device;

/**
 * 连接DLNA设备，连接成功后直接投放视频url
 */
- (void)connectDLNADevice:(UAControlDevice *)device url:(NSString *)url;

/**
 * 断开投屏连接
 */
- (void)disconnect;

/**
 * 统一控制暂停
 */
- (void)pause;

/**
 * 继续播放
 */
- (void)resume;

@end
