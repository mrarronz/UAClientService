//
//  UAUPnPHeader.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

static NSString *ssdpAddres = @"239.255.255.250";
static UInt16    ssdpPort = 1900;

static NSString *serviceAVTransport         = @"urn:schemas-upnp-org:service:AVTransport:1";
static NSString *serviceRenderingControl    = @"urn:schemas-upnp-org:service:RenderingControl:1";

static NSString *unitTime = @"REL_TIME";

static NSInteger kTimeoutInterval = 5;
static NSInteger kDelayTimeInterval = 30;

/**
 * DLNA指令的控制类型
 */
typedef NS_ENUM(NSInteger, UAUPnPServiceType) {
    /**
     * 数据传输
     */
    UAUPnPServiceTypeAVTransport,
    /**
     * 控制control控件
     */
    UAUPnPServiceTypeRenderControl
};

/**
 *  连接的设备类型
 */
typedef NS_ENUM(NSInteger, UADeviceType) {
    /**
     * 连接的是AirPlay设备
     */
    UADeviceTypeAirPlay,
    /**
     * 连接的是DLNA的设备
     */
    UADeviceTypeDLNA
};

/**
 *  投屏连接方式
 */
typedef NS_ENUM(NSInteger, UAConnectionType) {
    /**
     * AirPlay连接
     */
    UAConnectionTypeAirPlay,
    /**
     * DLNA连接
     */
    UAConnectionTypeDLNA,
    /**
     * 无连接（当前还没有连接到投屏设备）
     */
    UAConnectionTypeNone
};

typedef NS_ENUM(long, UAAirPlayActionType) {
    /**
     *  发送视频地址
     */
    UAAirPlayActionMedia = 1,
    /**
     *  发送图片
     */
    UAAirPlayActionImage = 2,
    /**
     *  发送协商请求
     */
    UAAirPlayActionReverse = 3,
    
    /**
     *  发送停止请求
     */
    UAAirPlayActionStop = 4,
    /**
     *  发送暂停请求
     */
    UAAirPlayActionPause = 5,
    /**
     *  发送播放请求
     */
    UAAirPlayActionPlay = 6,
    /**
     *  发送调整进度请求
     */
    UAAirPlayActionSeek = 7,
};
