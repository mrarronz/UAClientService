//
//  UAControlDevice.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAControlDevice.h"
#import "GDataXMLNode.h"
#import "UADefineHeader.h"

@interface UAControlDevice ()<GCDAsyncSocketDelegate>

@end

@implementation UAControlDevice

- (instancetype)init {
    self = [super init];
    if (self) {
        _imageQuality = 0.8;
        _avTransport = [[UAServiceModel alloc] init];
        _renderingControl = [[UAServiceModel alloc] init];
    }
    return self;
}

- (void)setDeviceArray:(NSArray *)deviceArray {
    _deviceArray = deviceArray;
    for (GDataXMLElement *element in deviceArray) {
        if ([element.name isEqualToString:@"friendlyName"]) {
            self.deviceName = [element stringValue];
        }
        else if ([element.name isEqualToString:@"modelName"]) {
            self.hostName = [element stringValue];
        }
        else if ([element.name isEqualToString:@"serviceList"]) {
            NSArray *serviceListArray = [element children];
            for (GDataXMLElement *listElement in serviceListArray) {
                if ([listElement.name isEqualToString:@"service"]) {
                    if ([[listElement stringValue] rangeOfString:serviceAVTransport].location != NSNotFound) {
                        self.avTransport.serviceArray = [listElement children]; 
                    }
                    else if ([[listElement stringValue] rangeOfString:serviceRenderingControl].location != NSNotFound){
                        self.renderingControl.serviceArray = [listElement children];
                    }
                }
            }
        }
    }
}

/**
 * 获取当前请求的类型
 */
+ (NSString *)typeWithTag:(long)tag {
    NSString *type;
    switch (tag) {
        case 1:
            type = @"UAAirplayActionMedia";
            break;
        case 2:
            type = @"UAAirplayActionImage";
            break;
        case 3:
            type = @"UAAirplayActionReverse";
            break;
        case 4:
            type = @"UAAirplayActionStop";
            break;
        case 5:
            type = @"UAAirplayActionPause";
            break;
        case 6:
            type = @"UAAirplayActionPlay";
            break;
        case 7:
            type = @"UAAirplayActionSeek";
            break;
        default:
            type = @"UAAirplayActionMedia";
            break;
    }
    return type;
}

#pragma mark - Send data

/**
 * 发送内容地址
 */
- (void)sendContentWithURL:(NSString *)url {
    [self sendContentWithURL:url progress:0];
}

/**
 * 发送内容并调整进度，跳转到指定的位置播放
 * @param progress 0~1之间
 */
- (void)sendContentWithURL:(NSString *)url progress:(float)progress {
    NSString *body = [[NSString alloc] initWithFormat:@"Content-Location: %@\r\n"
                      "Start-Position: %.1f\r\n\r\n", url, progress];
    NSInteger length = [body length];
    
    NSString *message = [[NSString alloc] initWithFormat:@"POST /play HTTP/1.1\r\n"
                         "Content-Length: %zd\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n%@", length, body];
    [self sendMessage:message action:UAAirplayActionMedia];
}

/**
 * 发送图片
 */
- (void)sendImage:(UIImage *)image {
    NSData *imageData = UIImageJPEGRepresentation(image, _imageQuality);
    NSInteger length = [imageData length];
    NSString *message = [[NSString alloc] initWithFormat:@"PUT /photo HTTP/1.1\r\n"
                         "Content-Length: %zd\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n", length];
    NSMutableData *messageData = [[NSMutableData alloc] initWithData:[message dataUsingEncoding:NSUTF8StringEncoding]];
    [messageData appendData:imageData];
    [self sendData:messageData action:UAAirplayActionImage];
}

/**
 * 发送协商请求
 */
- (void)reverse {
    NSString *message = @"POST /reverse HTTP/1.1\r\n"
    "Upgrade: PTTH/1.0\r\n"
    "Connection: Upgrade\r\n"
    "X-Apple-Purpose: event\r\n"
    "Content-Length: 0\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
    
    [self sendMessage:message action:UAAirplayActionReverse];
}

/**
 * 暂停播放
 */
- (void)pause {
    NSString *message = @"POST /rate?value=0.000000 HTTP/1.1\r\n"
    "Content-Length: 0\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
    
    [self sendMessage:message action:UAAirplayActionPause];
}

/**
 * 继续播放
 */
- (void)play {
    NSString *message = @"POST /rate?value=1.000000 HTTP/1.1\r\n"
    "Content-Length: 0\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
    
    [self sendMessage:message action:UAAirplayActionPlay];
}

/**
 * 停止播放
 */
- (void)stop {
    NSString *message = @"POST /stop HTTP/1.1\r\n"
    "Content-Length: 0\r\n"
    "User-Agent: MediaControl/1.0\r\n\r\n";
    
    [self sendMessage:message action:UAAirplayActionStop];
}

/**
 * 跳转进度
 */
- (void)seekToSeconds:(float)seconds {
    NSString *message = [NSString stringWithFormat:@"POST /scrub?position=%f HTTP/1.1\r\n"
                         "Content-Length: 0\r\n"
                         "User-Agent: MediaControl/1.0\r\n\r\n", seconds];
    
    [self sendMessage:message action:UAAirplayActionSeek];
}

#pragma mark - Private method

/**
 * 发送数据，同时记录当前发送的事件
 */
- (void)sendData:(NSData *)data action:(UAAirplayActionType)action {
    [self.socket writeData:data withTimeout:15 tag:action];
    [self.socket readDataWithTimeout:15 tag:action];
}

/**
 * 将字符消息转为NSData再进行发送
 */
- (void)sendMessage:(NSString *)message action:(UAAirplayActionType)action {
    [self sendData:[message dataUsingEncoding:NSUTF8StringEncoding] action:action];
}

@end
