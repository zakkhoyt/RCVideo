//
//  VWWUserDefaults.h
//  Synthesizer
//
//  Created by Zakk Hoyt on 2/17/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWUserDefaults : NSObject

+(BOOL)logGPS;
+(void)setLogGPS:(BOOL)log;

+(BOOL)logHeading;
+(void)setLogHeading:(BOOL)log;

+(BOOL)logAccelerometers;
+(void)setLogAccelerometers:(BOOL)log;

+(BOOL)logGyroscopes;
+(void)setLogGyroscopes:(BOOL)log;

+(BOOL)logMagnetometers;
+(void)setLogMagnetometers:(BOOL)log;

+(BOOL)logAttitude;
+(void)setLogAttitude:(BOOL)log;


+(BOOL)overlayDataOnVideo;
+(void)setOverlayDataOnVideo:(BOOL)overlay;

@end
