//
//  UAUPnPController.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAUPnPController.h"
#import "UAUPnPAction.h"
#import "UADefineHeader.h"
#import "GDataXMLNode.h"

@implementation UAUPnPController

- (instancetype)initWithDevice:(UAControlDevice *)device {
    self = [super init];
    if (self) {
        _device = device;
    }
    return self;
}

#pragma mark - Actions

- (void)setAVTransportURL:(NSString *)url {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"SetAVTransportURI"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:url forArgument:@"CurrentURI"];
    [action setValue:@"" forArgument:@"CurrentURIMetaData"];
    [self postRequestWithAction:action];
}

- (void)setNextAVTransportURL:(NSString *)url {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"SetNextAVTransportURI"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:url forArgument:@"NextURI"];
    [action setValue:@"" forArgument:@"NextURIMetaData"];
    [self postRequestWithAction:action];
}

- (void)play {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Play"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:@"1" forArgument:@"Speed"];
    [self postRequestWithAction:action];
}

- (void)pause {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Pause"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)stop {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Stop"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)next {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Next"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)previous {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Previous"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)seek:(float)relTime {
    [self seekToTarget:[NSString stringWithDurationTime:relTime] unit:unitTime];
}

- (void)seekToTarget:(NSString *)target unit:(NSString *)unit {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"Seek"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:unit forArgument:@"Unit"];
    [action setValue:target forArgument:@"Target"];
    [self postRequestWithAction:action];
}

- (void)getPositionInfo {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"GetPositionInfo"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)getTransportInfo {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"GetTransportInfo"];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [self postRequestWithAction:action];
}

- (void)getVolume {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"GetVolume"];
    [action setServiceType:UAUPnPServiceTypeRenderControl];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:@"Master" forArgument:@"Channel"];
    [self postRequestWithAction:action];
}

- (void)setVolumeValue:(NSString *)value {
    UAUPnPAction *action = [[UAUPnPAction alloc] initWithAction:@"SetVolume"];
    [action setServiceType:UAUPnPServiceTypeRenderControl];
    [action setValue:@"0" forArgument:@"InstanceID"];
    [action setValue:@"Master" forArgument:@"Channel"];
    [action setValue:value forArgument:@"DesiredVolume"];
    [self postRequestWithAction:action];
}

#pragma mark - Request

- (void)postRequestWithAction:(UAUPnPAction *)action {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURL *url = [NSURL URLWithString:[action urlWithDevice:_device]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    [request addValue:@"text/xml" forHTTPHeaderField:@"Content-Type"];
    [request addValue:[action SOAPAction] forHTTPHeaderField:@"SOAPAction"];
    request.HTTPBody = [[action XMLStringBody] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error || data == nil) {
            NSLog(@"DLNA Response error: %@", error);
            [self handleUndefinedResponse:[action XMLStringBody]];
        } else {
            [self handleResponseData:data];
        }
    }];
    [dataTask resume];
}

#pragma mark - Response

- (void)handleResponseData:(NSData *)data {
    GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithData:data options:0 error:nil];
    GDataXMLElement *xmlEle = [xmlDoc rootElement];
    NSArray *bigArray = [xmlEle children];
    for (int i = 0; i < [bigArray count]; i++) {
        GDataXMLElement *element = [bigArray objectAtIndex:i];
        NSArray *needArray = [element children];
        if ([[element name] hasSuffix:@"Body"]) {
            [self handleResultsWithArray:needArray];
        } else {
            [self handleUndefinedResponse:[xmlEle XMLString]];
        }
    }
}

- (void)handleResultsWithArray:(NSArray *)array{
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *ele = [array objectAtIndex:i];
        if ([[ele name] hasSuffix:@"SetAVTransportURIResponse"]) {
            [self handleAVTransportURLResponse];
            [self getTransportInfo];
            
        } else if ([[ele name] hasSuffix:@"SetNextAVTransportURIResponse"]){
            [self handleSetNextAVTransportURLResponse];
            
        } else if ([[ele name] hasSuffix:@"PauseResponse"]){
            [self handlePauseResponse];
            
        } else if ([[ele name] hasSuffix:@"PlayResponse"]){
            [self handlePlayResponse];
            
        } else if ([[ele name] hasSuffix:@"StopResponse"]){
            [self handleStopResponse];
            
        } else if ([[ele name] hasSuffix:@"SeekResponse"]){
            [self handleSeekResponse];
            
        } else if ([[ele name] hasSuffix:@"NextResponse"]){
            [self handleNextResponse];
            
        } else if ([[ele name] hasSuffix:@"PreviousResponse"]){
            [self handlePreviousResponse];
            
        } else if ([[ele name] hasSuffix:@"SetVolumeResponse"]){
            [self handleSetVolumeResponse];
            
        } else if ([[ele name] hasSuffix:@"GetVolumeResponse"]){
            [self handleGetVolumeResponseWithArray:[ele children]];
            
        } else if ([[ele name] hasSuffix:@"GetPositionInfoResponse"]){
            [self handleGetPlayPositionResponse:[ele children]];
            
        } else if ([[ele name] hasSuffix:@"GetTransportInfoResponse"]){
            [self handleTransportInfoResponseWithArray:[ele children]];
        } else {
            [self handleUndefinedResponse:[ele XMLString]];
        }
    }
}

#pragma mark - Delegate

- (void)handleAVTransportURLResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaSetAVTransportURLResponse)]) {
        [self.delegate dlnaSetAVTransportURLResponse];
    }
}

- (void)handleTransportInfoResponseWithArray:(NSArray *)array {
    UAUPnPTransportInfo *transport = [[UAUPnPTransportInfo alloc] init];
    transport.transportArray = array;
    
    if ([self.delegate respondsToSelector:@selector(dlnaGetTransportInfoResponse:)]) {
        [self.delegate dlnaGetTransportInfoResponse:transport];
    }
}

- (void)handlePlayResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaPlayResponse)]) {
        [self.delegate dlnaPlayResponse];
    }
}

- (void)handlePauseResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaPauseResponse)]) {
        [self.delegate dlnaPauseResponse];
    }
}

- (void)handleStopResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaStopResponse)]) {
        [self.delegate dlnaStopResponse];
    }
}

- (void)handleSeekResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaSeekResponse)]) {
        [self.delegate dlnaSeekResponse];
    }
}

- (void)handlePreviousResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaPreviousResponse)]) {
        [self.delegate dlnaPreviousResponse];
    }
}

- (void)handleNextResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaNextResponse)]) {
        [self.delegate dlnaNextResponse];
    }
}

- (void)handleSetVolumeResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaSetVolumeResponse)]) {
        [self.delegate dlnaSetVolumeResponse];
    }
}

- (void)handleSetNextAVTransportURLResponse {
    if ([self.delegate respondsToSelector:@selector(dlnaSetNextAVTransportURLResponse)]) {
        [self.delegate dlnaSetNextAVTransportURLResponse];
    }
}

- (void)handleGetVolumeResponseWithArray:(NSArray *)array {
    for (int i = 0; i < array.count; i++) {
        GDataXMLElement *eleXml = [array objectAtIndex:i];
        if ([[eleXml name] isEqualToString:@"CurrentVolume"]) {
            if ([self.delegate respondsToSelector:@selector(dlnaGetVolumeResponse:)]) {
                [self.delegate dlnaGetVolumeResponse:[eleXml stringValue]];
            }
        }
    }
}

- (void)handleGetPlayPositionResponse:(NSArray *)array {
    UAUPnPAVPositionInfo *avPosition = [[UAUPnPAVPositionInfo alloc] init];
    avPosition.positionArray = array;
    
    if ([self.delegate respondsToSelector:@selector(dlnaGetPositionInfoResponse:)]) {
        [self.delegate dlnaGetPositionInfoResponse:avPosition];
    }
}

- (void)handleUndefinedResponse:(NSString *)xmlString {
    if ([self.delegate respondsToSelector:@selector(dlnaUndefinedResponse:)]) {
        [self.delegate dlnaUndefinedResponse:xmlString];
    }
}

@end
