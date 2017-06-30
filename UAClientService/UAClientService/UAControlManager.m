//
//  UAControlManager.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAControlManager.h"
#import "GDataXMLNode.h"

@interface UAControlManager ()
<NSNetServiceBrowserDelegate,
NSNetServiceDelegate,
GCDAsyncSocketDelegate,
GCDAsyncUdpSocketDelegate,
UAUPnpControllerDelegate>

@property (nonatomic, strong) GCDAsyncSocket *socket;
@property (nonatomic, strong) GCDAsyncUdpSocket *udpSocket;
@property (nonatomic, strong) UAControlDevice *tempDevice;
@property (nonatomic, strong) NSMutableArray *dlnaDevices;

@end

@implementation UAControlManager

+ (UAControlManager *)sharedManager {
    static UAControlManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _foundServices = [NSMutableArray array];
        _dlnaDevices = [NSMutableArray array];
        _connectType = UAConnectionTypeNone;
    }
    return self;
}

#pragma mark - Search

- (NSString *)dlnaSearchString {
    return [NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\n"
            "HOST: %@:%d\r\n"
            "MAN: \"ssdp:discover\"\r\n"
            "MX: 3\r\nST: %@\r\n"
            "USER-AGENT: iOS UPnP/1.1 Xuetang365/1.0\r\n\r\n", ssdpAddres, ssdpPort, serviceAVTransport];
}

/**
 * 开始搜索设备，30秒后停止搜索
 */
- (void)startSearching {
    [self.foundServices removeAllObjects];
    [self.dlnaDevices removeAllObjects];
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    // search DLNA devices
    [self searchDLNA];
    
    // search airplay
    [self.serviceBrowser searchForServicesOfType:@"_airplay._tcp" inDomain:@"local."];
    [self performSelector:@selector(stopSearching) withObject:nil afterDelay:kDelayTimeInterval];
}

/**
 * 搜索DLNA设备
 */
- (void)searchDLNA {
    NSError *error;
    NSData *sendData = [[self dlnaSearchString] dataUsingEncoding:NSUTF8StringEncoding];
    [self.udpSocket sendData:sendData toHost:ssdpAddres port:ssdpPort withTimeout:kTimeoutInterval tag:0];
    [self.udpSocket bindToPort:ssdpPort error:&error];
    [self.udpSocket joinMulticastGroup:ssdpAddres error:&error];
    [self.udpSocket beginReceiving:&error];
    if (error) {
        [self stopDLNA];
        NSLog(@"停止DLNA搜索，error:%@", error);
    }
}

/**
 * 停止搜索
 */
- (void)stopSearching {
    [self.serviceBrowser stop];
    if (self.connectType != UAConnectionTypeDLNA) {
        [self stopDLNA];
    }
}

/**
 * 停止DLNA设备的搜索
 */
- (void)stopDLNA {
    if (!self.udpSocket.isClosed) {
        [self.udpSocket close];
        _udpSocket = nil;
    }
}

#pragma mark - Connecting

/**
 * 连接AirPlay设备
 */
- (void)connectAirplayDevice:(UAControlDevice *)device {
    
    self.tempDevice = device;
    // 连接AirPlay设备
    NSError *error;
    [self.socket connectToHost:device.hostName onPort:device.port error:&error];
    if (error) {
        NSLog(@"连接设备失败: %@, error: %@", device.deviceName, error);
    } else {
        _connectType = UAConnectionTypeAirplay;
    }
}

/**
 * 连接DLNA设备，连接成功后直接投放视频url
 */
- (void)connectDLNADevice:(UAControlDevice *)device url:(NSString *)url {
    self.tempDevice = device;
    _dlnaController = [[UAUPnPController alloc] initWithDevice:device];
    _dlnaController.delegate = self;
    [_dlnaController setAVTransportURL:url];
}

/**
 * 断开投屏连接
 */
- (void)disconnect {
    if (!self.connectedDevice) {
        return;
    }
    if (_connectType == UAConnectionTypeAirplay) {
        [self.connectedDevice stop];
        [self.socket disconnect];
        _socket = nil;
    } else {
        [_dlnaController stop];
        [self stopDLNA];
    }
    self.connectedDevice = nil;
    _connectType = UAConnectionTypeNone;
}

/**
 * 统一控制暂停
 */
- (void)pause {
    if (_isPlayPaused) {
        return;
    }
    if (self.connectedDevice) {
        if (self.connectType == UAConnectionTypeAirplay) {
            [self.connectedDevice pause];
        } else {
            [self.dlnaController pause];
        }
        _isPlayPaused = YES;
    }
}

/**
 * 继续播放
 */
- (void)resume {
    if (!_isPlayPaused) {
        return;
    }
    if (self.connectedDevice) {
        if (self.connectType == UAConnectionTypeAirplay) {
            [self.connectedDevice play];
        } else {
            [self.dlnaController play];
        }
        _isPlayPaused = NO;
    }
}

#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {
    service.delegate = self;
    [service resolveWithTimeout:kTimeoutInterval];
    [self.foundServices addObject:service];
    if (!moreComing) {
        
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)browser {
    NSLog(@"Stop searching device.....");
}

#pragma mark - NSNetServiceDelegate

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    
    UAControlDevice *device = [[UAControlDevice alloc] init];
    device.deviceName = sender.name;
    device.deviceType = UADeviceTypeAirplay;
    device.hostName = sender.hostName;
    device.port = sender.port;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFindDevice:)]) {
        [self.delegate manager:self didFindDevice:device];
    }
    // 自动连接第一个搜索到的设备
    if (self.autoConnect && !self.connectedDevice) {
        [self connectAirplayDevice:device];
    }
}

#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    UAControlDevice *device = self.tempDevice;
    device.socket = sock;
    device.socket.delegate = self;
    self.connectedDevice = device;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didConnectToDevice:)]) {
        [self.delegate manager:self didConnectToDevice:device];
    }
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    NSString *type = [UAControlDevice typeWithTag:tag];
    NSLog(@"已发送请求：%@", type);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSString *type = [UAControlDevice typeWithTag:tag];
    NSLog(@"request: %@\n response:\n%@", type, string);
    if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didCompleteActionWithTag:)]) {
        [self.delegate manager:self didCompleteActionWithTag:tag];
    }
}

#pragma mark - GCDAsyncUdpSocketDelegate

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"DLNA发送指令成功");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"DLNA指令发送失败");
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"udpSocket已关闭");
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didStopSearchingWithServiceCount:)]) {
            NSInteger count = self.dlnaDevices.count + self.foundServices.count;
            [self.delegate manager:self didStopSearchingWithServiceCount:count];
        }
    });
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSURL *location = [self deviceUrlWithData:data];
    if (location) {
        [self getDeviceInfoWithLocation:location];
    }
}

// 解析搜索设备获取Location
- (NSURL *)deviceUrlWithData:(NSData *)data {
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *subArray = [string componentsSeparatedByString:@"\n"];
    for (int j = 0 ; j < subArray.count; j++){
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@": "];
        if ([dicArray[0] isEqualToString:@"LOCATION"] || [dicArray[0] isEqualToString:@"Location"]) {
            if (dicArray.count > 1) {
                NSString *location = dicArray[1];
                location = [location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSURL *url = [NSURL URLWithString:location];
                return url;
            }
        }
    }
    return nil;
}

- (void)getDeviceInfoWithLocation:(NSURL *)url {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest  *request=[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if(error || data == nil){
                NSLog(@"\nDLNA device error: %@", error);
            } else {
                UAControlDevice *model = [[UAControlDevice alloc] init];
                model.urlHeader = [NSString stringWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
                NSString *_dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:_dataStr options:0 error:nil];
                GDataXMLElement *xmlEle = [xmlDoc rootElement];
                NSArray *xmlArray = [xmlEle children];
                
                for (int i = 0; i < [xmlArray count]; i++) {
                    GDataXMLElement *element = [xmlArray objectAtIndex:i];
                    if ([[element name] isEqualToString:@"device"]) {
                        model.deviceArray = [element children];
                        continue;
                    }
                }
                model.deviceType = UADeviceTypeDLNA;
                if (model.avTransport.controlURL) {
                    if (![self filterDevice:model]) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didFindDevice:)]) {
                                [self.delegate manager:self didFindDevice:model];
                            }
                        });
                    }
                }
            }
        }];
        [dataTask resume];
    });
}

/**
 * 如果已经存在同样的DLNA设备，则不再添加
 */
- (BOOL)filterDevice:(UAControlDevice *)model {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"urlHeader = %@", model.urlHeader];
    NSArray *results = [self.dlnaDevices filteredArrayUsingPredicate:predicate];
    if (results.count > 0) {
        return YES;
    }
    [self.dlnaDevices addObject:model];
    return NO;
}

#pragma mark - ZFDLNAResponseDelegate

/// 设置url的回调
- (void)dlnaSetAVTransportURLResponse {
    _connectType = UAConnectionTypeDLNA;
    _connectedDevice = self.tempDevice;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(manager:didConnectToDevice:)]) {
            [self.delegate manager:self didConnectToDevice:self.tempDevice];
        }
    });
}

/// 获取播放状态的回调
- (void)dlnaGetTransportInfoResponse:(UAUPnPTransportInfo *)info {
    
}

/// 播放的回调
- (void)dlnaPlayResponse {
    
}

/// 暂停的回调
- (void)dlnaPauseResponse {
    
}

/// 停止投屏的回调
- (void)dlnaStopResponse {
    
}

/// 跳转进度的回调
- (void)dlnaSeekResponse {
    
}

/// 播放上一个的回调
- (void)dlnaPreviousResponse {
    
}

/// 播放下一个的回调
- (void)dlnaNextResponse {
    
}

/// 设置音量的回调
- (void)dlnaSetVolumeResponse {
    
}

/// 设置下一个url的回调
- (void)dlnaSetNextAVTransportURLResponse {
    
}

/// 获取音频信息
- (void)dlnaGetVolumeResponse:(NSString *)volume {
    
}

/// 获取播放进度
- (void)dlnaGetPositionInfoResponse:(UAUPnPAVPositionInfo *)info {
    
}

/// 未定义的响应/错误
- (void)dlnaUndefinedResponse:(NSString *)xmlString {
    
}

#pragma mark - Init property

- (NSNetServiceBrowser *)serviceBrowser {
    if (!_serviceBrowser) {
        _serviceBrowser = [[NSNetServiceBrowser alloc] init];
        _serviceBrowser.delegate = self;
    }
    return _serviceBrowser;
}

- (GCDAsyncSocket *)socket {
    if (!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self
                                             delegateQueue:dispatch_get_main_queue()];
    }
    return _socket;
}

- (GCDAsyncUdpSocket *)udpSocket {
    if (!_udpSocket) {
        _udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self
                                                   delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        
    }
    return _udpSocket;
}

@end
