//
//  UAControlDevice.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

#import "UAServiceModel.h"

/**
 *  连接的设备类型
 */
typedef NS_ENUM(NSInteger, UADeviceType) {
    /**
     * 连接的是AirPlay设备
     */
    UADeviceTypeAirplay,
    /**
     * 连接的是DLNA的设备
     */
    UADeviceTypeDLNA
};

@interface UAControlDevice : NSObject

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

@end
