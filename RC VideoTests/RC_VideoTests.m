//
//  RC_VideoTests.m
//  RC VideoTests
//
//  Created by Zakk Hoyt on 3/10/14.
//  Copyright (c) 2014 Zakk Hoyt. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VWWFileController.h"
@interface RC_VideoTests : XCTestCase

@end

@implementation RC_VideoTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDocumentsController
{
    NSURL *url = [VWWFileController urlForDocumentsDirectory];
    XCTAssertNotNil(url, @"Could not get url for documents directory");
    VWW_LOG_INFO(@"path for documents directory: %@", url);
    
    NSString *path = [VWWFileController pathForDocumentsDirectory];
    XCTAssertNotNil(path, @"Could not get path for documents directory");
    VWW_LOG_INFO(@"url for documents directory: %@", [VWWFileController urlForDocumentsDirectory]);
    
    NSArray *videos = [VWWFileController urlsForVideos];
    XCTAssertNotNil(videos, @"Could not get list of videos on disk");
    VWW_LOG_INFO(@"videos: %@", videos);
    
    VWW_LOG_TRACE;
}

@end
