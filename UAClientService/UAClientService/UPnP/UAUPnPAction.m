//
//  UAUPnPAction.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAUPnPAction.h"
#import "GDataXMLNode.h"
#import "UADefineHeader.h"
#import "UAUPnPInfoModel.h"
#import "UAServiceModel.h"

@interface UAUPnPAction ()

@property (nonatomic, copy) NSString *action;
@property (nonatomic, strong) GDataXMLElement *XMLElement;

@end

@implementation UAUPnPAction

- (instancetype)initWithAction:(NSString *)action {
    self = [super init];
    if (self) {
        _action = action;
        _serviceType = UAUPnPServiceTypeAVTransport;
        NSString *name = [NSString stringWithFormat:@"u:%@", _action];
        self.XMLElement = [GDataXMLElement elementWithName:name];
    }
    return self;
}

- (void)setValue:(NSString *)value forArgument:(NSString *)name {
    [self.XMLElement addChild:[GDataXMLElement elementWithName:name stringValue:value]];
}

- (NSString *)currentServiceType {
    if (_serviceType == UAUPnPServiceTypeAVTransport) {
        return serviceAVTransport;
    } else {
        return serviceRenderingControl;
    }
}

- (NSString *)SOAPAction {
    if (_serviceType == UAUPnPServiceTypeAVTransport) {
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceAVTransport, _action];
    } else {
        return [NSString stringWithFormat:@"\"%@#%@\"", serviceRenderingControl, _action];
    }
}

- (NSString *)urlWithDevice:(UAControlDevice *)device {
    if (_serviceType == UAUPnPServiceTypeAVTransport) {
        return [self urlWithModel:device.avTransport header:device.urlHeader];
    } else {
        return [self urlWithModel:device.renderingControl header:device.urlHeader];
    }
}

- (NSString *)XMLStringBody {
    GDataXMLElement *element = [GDataXMLElement elementWithName:@"s:Envelope"];
    [element addChild:[GDataXMLElement elementWithName:@"s:encodingStyle" stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [element addChild:[GDataXMLElement attributeWithName:@"xmlns:s" stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [element addChild:[GDataXMLElement attributeWithName:@"xmlns:u" stringValue:[self currentServiceType]]];
    
    GDataXMLElement *command = [GDataXMLElement elementWithName:@"s:Body"];
    [command addChild:self.XMLElement];
    
    [element addChild:command];
    return element.XMLString;
}

#pragma mark - Private method

- (NSString *)urlWithModel:(UAServiceModel *)model header:(NSString *)header {
    if ([[model.controlURL substringToIndex:1] isEqualToString:@"/"]) {
        return [NSString stringWithFormat:@"%@%@", header, model.controlURL];
    } else {
        return [NSString stringWithFormat:@"%@/%@", header, model.controlURL];
    }
}

@end
