//
//  SMMotion.h
//  Smile_iOS
//
//  Created by Zakk Hoyt on 1/14/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//


#import <Foundation/Foundation.h>
@protocol VWWModelProtocol <NSObject>
@required
-(id)initWithDictionary:(NSDictionary*)dictionary;
-(NSDictionary*)dictionary;
-(NSString *)description;
@end

