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

@implementation UAControlDevice

- (instancetype)init {
    self = [super init];
    if (self) {
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

@end
