//
//  UAServiceModel.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAServiceModel.h"
#import "GDataXMLNode.h"

@implementation UAServiceModel

- (void)setServiceArray:(NSArray *)serviceArray {
    _serviceArray = serviceArray;
    for (GDataXMLElement *element in serviceArray) {
        if ([element.name isEqualToString:@"serviceType"]) {
            self.serviceType = [element stringValue];
        }
        else if ([element.name isEqualToString:@"serviceId"]) {
            self.serviceId = [element stringValue];
        }
        else if ([element.name isEqualToString:@"controlURL"]) {
            self.controlURL = [element stringValue];
        }
        else if ([element.name isEqualToString:@"eventSubURL"]) {
            self.eventSubURL = [element stringValue];
        }
        else if ([element.name isEqualToString:@"SCPDURL"]) {
            self.SCPDURL = [element stringValue];
        }
    }
}

@end
