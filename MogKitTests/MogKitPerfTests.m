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

- (NSArray *)arrayWithInts:(int)numberOfInts
{
    NSMutableArray *mArray = [NSMutableArray new];
    for (int i = 0; i < numberOfInts; ++i) {
        [mArray addObject:@(i)];
    }
    return [mArray copy];
}

- (NSArray *)expectedByAdding:(int)value toEachElementOfArrayOfInts:(NSArray *)array
{
    NSMutableArray *mArray = [NSMutableArray new];
    for (NSNumber *number in array) {
        [mArray addObject:@(number.intValue + value)];
    }
    return [mArray copy];
}

- (void)testPerformanceMappingArrayTransduce
{
    NSArray *array = [self arrayWithInts:100000];
    NSArray *expected = [self expectedByAdding:100 toEachElementOfArrayOfInts:array];

    // Measure performance of standard impl.
    [self measureBlock:^{
        NSArray *result = [array mog_transduce:MOGMap(^id(NSNumber *number) {
            return @(number.intValue + 100);
        })];

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceMappingArrayLooping
{
    NSArray *array = [self arrayWithInts:100000];
    NSArray *expected = [self expectedByAdding:100 toEachElementOfArrayOfInts:array];

    [self measureBlock:^{
        NSMutableArray *result = [NSMutableArray new];
        for (NSNumber *number in array) {
            [result addObject:@(number.intValue + 100)];
        }

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceComposing
{
    NSArray *array = [self arrayWithInts:100000];

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

        MOGTransformation xform = MOGComposeArray(transducers);

        NSArray *result = MOGTransform(array, MOGArrayReducer(), xform);

        XCTAssertEqualObjects(array, result);
    }];
}

- (void)testPerformanceChaining
{
    NSArray *array = [self arrayWithInts:100000];

    [self measureBlock:^{
        NSMutableArray *array1 = MOGTransform(array, MOGArrayReducer(), MOGMap(^id(NSNumber *number) {
            return @(number.intValue + 100);
        }));
        NSMutableArray *array2 = MOGTransform(array1, MOGArrayReducer(), MOGFilter(^BOOL(NSNumber *number) {
            return YES;
        }));
        NSMutableArray *result = MOGTransform(array2, MOGArrayReducer(), MOGMap(^id(NSNumber *number) {
            return @(number.intValue - 100);
        }));

        XCTAssertEqualObjects(array, result);
    }];
}

@end