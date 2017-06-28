//
//  UAControlManager.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/28.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAControlManager.h"

@implementation UAControlManager

+ (UAControlManager *)sharedManager {
    static UAControlManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

@end
