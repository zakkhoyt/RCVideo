//
//  VWWFileController.m
//  RC Video
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import "VWWFileController.h"

@implementation VWWFileController


+(NSURL*)urlForDocumentsDirectory{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSURL *url = [NSURL fileURLWithPath:documentsDirectory];
    return url;
}

+(NSString*)pathForDocumentsDirectory{
    NSURL *url = [VWWFileController urlForDocumentsDirectory];
    return url.path;
}

// file:///var/mobile/Applications/FD5AEE23-DDB5-401E-A616-83DA8C9F2778/Documents/FinalVideo-431.mov
+(NSArray*)urlsForVideos{
    NSURL *documentsDirURL = [VWWFileController urlForDocumentsDirectory];
    NSError *error;
    NSArray *files = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:documentsDirURL includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsHiddenFiles error:&error];
    NSMutableArray *videos = [@[] mutableCopy];
    for(int index = 0; index < files.count; index++){
        NSString * file = [files objectAtIndex:index];
        if([[file pathExtension] compare:@"mov"] == NSOrderedSame){
            [videos addObject:file];
        }
    }
    return videos;
}


+(BOOL)deleteVideoAtURL:(NSURL*)url{
    return YES;
}
+(BOOL)deleteAllVideos{
    return YES;
}

@end
