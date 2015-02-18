//
//  TransformationKitTests.m
//  TransformationKit
//
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TransformationKit.h"
#import "NSArray+TransformationKit.h"


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

- (void)testMappingEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = [array tk_map:^id(id o) {
        return o;
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

- (void)testFilteringEmpty
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = [array tk_filter:^BOOL(id o) {
        return YES;
    }];

    XCTAssertEqualObjects(expected, result);
}

- (void)testArrayFlatten
{
    NSArray *array = @[@[@1, @2, @3], @[@4, @5, @6], @[@7, @8, @9]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6, @7, @8, @9];
    NSArray *result = [array tk_concat];

    XCTAssertEqualObjects(expected, result);
}

- (void)testComposeTwoTransducers
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    NSArray *expected = @[@6, @12, @18];
    TKTransducer xform = TKCompose(
            TKMapping(^id(NSNumber *number) { return @(number.intValue * 3); }),
            TKFiltering(^BOOL(NSNumber *number) { return number.intValue % 2 == 0; })
    );

    NSArray *result = TKTransduce(array.objectEnumerator, @[], xform, arrayAppendReducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testComposeArrayOfTransducers
{
    NSArray *array = @[@50, @500, @5000, @50000];
    NSArray *expected = @[@50, @500];
    NSArray *transducers = @[
            TKMapping(^id(NSNumber *number) { return [NSString stringWithFormat:@"%@", number]; }),
            TKFiltering(^BOOL(NSString *str) { return str.length < 4; }),
            TKMapping(^id(NSString *str) { return @(str.intValue); })
    ];
    TKTransducer xform = TKComposeArray(transducers);
    NSArray *result = TKTransduce(array.objectEnumerator, @[], xform, arrayAppendReducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
