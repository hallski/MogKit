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
        NSArray *result = MOGTransduce(array.objectEnumerator, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                       MOGMapTransducer(^id(NSNumber *number) {
                                           return @(number.intValue + 100);
                                       }));

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
                MOGMapTransducer(^id(NSNumber *number) {
                    return @(number.intValue + 100);
                }),
                MOGFilterTransducer(^BOOL(NSNumber *number) {
                    return YES;
                }),
                MOGMapTransducer(^id(NSNumber *number) {
                    return @(number.intValue - 100);
                })
        ];

        MOGTransducer xform = MOGComposeArray(transducers);

        NSArray *result = MOGTransduce(array.objectEnumerator, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                       xform);

        XCTAssertEqualObjects(array, result);
    }];
}

- (void)testPerformanceChaining
{
    NSArray *array = [self arrayWithInts:100000];

    [self measureBlock:^{
        NSMutableArray *array1 = MOGTransduce(array, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                              MOGMapTransducer(^id(NSNumber *number) {
                                                  return @(number.intValue + 100);
                                              }));
        NSMutableArray *array2 = MOGTransduce(array1, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                              MOGFilterTransducer(^BOOL(NSNumber *number) {
                                                  return YES;
                                              }));
        NSMutableArray *result = MOGTransduce(array2, MOGMutableArrayAppendReducer(), [NSMutableArray new],
                                              MOGMapTransducer(^id(NSNumber *number) {
                                                  return @(number.intValue - 100);
                                              }));

        XCTAssertEqualObjects(array, result);
    }];
}

@end