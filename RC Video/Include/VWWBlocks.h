//
//  SMBlocks.h
//  Smile_iOS
//
//  Created by Zakk Hoyt on 1/13/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#ifndef Smile_iOS_SMBlocks_h
#define Smile_iOS_SMBlocks_h


@class CLLocation;
typedef void (^VWWArrayBlock)(NSArray *array);
typedef void (^VWWBoolBlock)(BOOL success);
typedef void (^VWWCLLocationBlock)(CLLocation *location);
typedef void (^VWWDictionaryBlock)(NSDictionary *dictionary);
typedef void (^VWWEmptyBlock)();
typedef void (^VWWErrorBlock)(NSError *error);
typedef void (^VWWErrorStringBlock)(NSError *error, NSString *description);
typedef void (^VWWJSONBlock)(id json);
typedef void (^VWWIntegerBlock)(NSInteger index);
typedef void (^VWWMutableArrayBlock)(NSMutableArray *array);
typedef void (^VWWMutableDictionaryBlock)(NSMutableDictionary *dictionary);
typedef void (^VWWOrderedSetBlock)(NSOrderedSet *set);
typedef void (^VWWProgessBlock)(NSInteger totalBytesSent, NSInteger totalBytesExpectedToSend);
typedef void (^VWWSetBlock)(NSOrderedSet *set);
typedef void (^VWWStringBlock)(NSString *string);
typedef void (^VWWUIntegerBlock)(NSUInteger index);
typedef void (^VWWURLErrorBlock)(NSURL *url, NSError *error);
#endif
