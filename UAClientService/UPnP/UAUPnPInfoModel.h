//
//  UAUPnPInfoModel.h
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (UPnP)

+ (NSString *)stringWithDurationTime:(float)timeValue;
- (float)durationTime;

@end

@interface UAUPnPAVPositionInfo : NSObject

@property (nonatomic, assign) float trackDuration;
@property (nonatomic, assign) float absTime;
@property (nonatomic, assign) float relTime;
@property (nonatomic, strong) NSArray *positionArray;

@end

@interface UAUPnPTransportInfo : NSObject

@property (nonatomic, copy) NSString *currentTransportState;
@property (nonatomic, copy) NSString *currentTransportStatus;
@property (nonatomic, copy) NSString *currentSpeed;
@property (nonatomic, strong) NSArray *transportArray;

@end
