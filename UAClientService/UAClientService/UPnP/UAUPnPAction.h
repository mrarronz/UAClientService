//
//  UAUPnPAction.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAControlDevice.h"

typedef NS_ENUM(NSInteger, UAUPnPServiceType) {
    UAUPnPServiceTypeAVTransport,
    UAUPnPServiceTypeRenderControl
};

@interface UAUPnPAction : NSObject

@property (nonatomic, assign) UAUPnPServiceType serviceType;

- (instancetype)initWithAction:(NSString *)action;

- (void)setValue:(NSString *)value forArgument:(NSString *)name;

- (NSString *)currentServiceType;

- (NSString *)SOAPAction;

- (NSString *)urlWithDevice:(UAControlDevice *)device;

- (NSString *)XMLStringBody;

@end
