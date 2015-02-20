//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MogKit.h"


@interface MogKitPerfTests : XCTestCase
@end

@implementation MogKitPerfTests

- (NSArray *)testArrayWithInts:(int)numberOfInts
{
    NSMutableArray *mArray = [NSMutableArray new];
    for (int i = 0; i < numberOfInts; ++i) {
        [mArray addObject:@(i)];
    }
    return [mArray copy];
}

- (void)testPerformanceSmallArrayMap
{
    NSArray *array = [self testArrayWithInts:10];

    // Measure performance of standard impl.
    [self measureBlock:^{
        NSArray *expected = array;
        NSArray *result = MOGTransduce(array.objectEnumerator, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                       MOGMap(^id(id o) {
                                           return o;
                                       }));

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceWithBigArrayMap
{
    NSArray *array = [self testArrayWithInts:10000];

    // Measure performance of standard impl.
    [self measureBlock:^{
        NSArray *expected = array;
        NSArray *result = MOGTransduce(array.objectEnumerator, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                       MOGMap(^id(id o) {
                                           return o;
                                       }));

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceComposing
{
    NSArray *array = [self testArrayWithInts:100000];

    [self measureBlock:^{
        NSArray *transducers = @[
                MOGMap(^id(NSNumber *number) {
                    return @(number.intValue + 100);
                }),
                MOGFilter(^BOOL(NSNumber *number) {
                    return YES;
                }),
                MOGMap(^id(NSNumber *number) {
                    return @(number.intValue - 100);
                })
        ];

        MOGTransducer xform = MOGComposeTransducersArray(transducers);

        NSArray *result = MOGTransduce(array.objectEnumerator, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                       xform);

        XCTAssertEqualObjects(array, result);
    }];
}

@end