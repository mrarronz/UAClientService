//
//  UAUPnPInfoModel.m
//  UAClientService
//
//  Created by Arron Zhu on 2017/6/27.
//  Copyright © 2017年 mrarronz. All rights reserved.
//

#import "UAUPnPInfoModel.h"
#import "GDataXMLNode.h"

@implementation NSString (UPnP)

+ (NSString *)stringWithDurationTime:(float)timeValue {
    return [NSString stringWithFormat:@"%02d:%02d:%02d",
            (int)(timeValue / 3600.0),
            (int)(fmod(timeValue, 3600.0) / 60.0),
            (int)fmod(timeValue, 60.0)];
}

- (float)durationTime {
    NSArray *timeStrings = [self componentsSeparatedByString:@":"];
    NSInteger timeStringsCount = [timeStrings count];
    if (timeStringsCount < 3) {
        return -1.0f;
    }
    float durationTime = 0.0;
    for (NSInteger i = 0; i < timeStringsCount; i++) {
        NSString *timeString = [timeStrings objectAtIndex:i];
        int timeIntValue = [timeString intValue];
        switch (i) {
            case 0: // HH
                durationTime += timeIntValue * (60 * 60);
                break;
            case 1: // MM
                durationTime += timeIntValue * 60;
                break;
            case 2: // SS
                durationTime += timeIntValue;
                break;
            case 3: // .F?
                durationTime += timeIntValue * 0.1;
                break;
            default:
                break;
        }
    }
    return durationTime;
}

@end

@implementation UAUPnPAVPositionInfo

- (void)setPositionArray:(NSArray *)positionArray {
    _positionArray = positionArray;
    for (GDataXMLElement *element in positionArray) {
        if ([element.name isEqualToString:@"TrackDuration"]) {
            self.trackDuration = [[element stringValue] durationTime];
        }
        else if ([element.name isEqualToString:@"RelTime"]) {
            self.relTime = [[element stringValue] durationTime];
        }
        else if ([element.name isEqualToString:@"AbsTime"]) {
            self.absTime = [[element stringValue] durationTime];
        }
    }
}

@end

@implementation UAUPnPTransportInfo

- (void)setTransportArray:(NSArray *)transportArray {
    _transportArray = transportArray;
    for (GDataXMLElement *element in transportArray) {
        if ([element.name isEqualToString:@"CurrentTransportState"]) {
            self.currentTransportState = [element stringValue];
        }
        else if ([element.name isEqualToString:@"CurrentTransportStatus"]) {
            self.currentTransportStatus = [element stringValue];
        }
        else if ([element.name isEqualToString:@"CurrentSpeed"]) {
            self.currentSpeed = [element stringValue];
        }
    }
}

@end
