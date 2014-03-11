//
//  VWWFileController.h
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VWWFileController : NSObject
+(NSURL*)urlForDocumentsDirectory;
+(NSString*)pathForDocumentsDirectory;

+(NSArray*)urlsForVideos;
+(BOOL)deleteVideoAtURL:(NSURL*)url;
+(BOOL)deleteAllVideos;
@end
