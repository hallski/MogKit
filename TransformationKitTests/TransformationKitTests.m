//
//  TransformationKitTests.m
//  TransformationKit
//
//  Created by Mikael Hallendal on 18/02/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TransformationKit.h"


@interface TransformationKitTests : XCTestCase

@end

@implementation TransformationKitTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testMapping
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = [array tk_map:^id(NSNumber *number) {
        return @(number.intValue + 10);
    }];

    XCTAssertEqualObjects(expected, result);
}

- (void)testFiltering
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = [array tk_filter:^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }];

    XCTAssertEqualObjects(expected, result);
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
