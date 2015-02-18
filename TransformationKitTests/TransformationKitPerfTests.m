#import <SenTestingKit/SenTestingKit.h>
#import <XCTest/XCTest.h>
#import "TransformationKit.h"
#import "NSArray+TransformationKit.h"


@interface TransformationKitPerfTests : XCTestCase
@end

@implementation TransformationKitPerfTests

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
        NSArray *result = [array tk_map:^id(id o) {
            return o;
        }];

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceSmallArrayWithMutableArray
{
    NSArray *array = [self testArrayWithInts:10];

    // Measure as a possible optimization in NSArray::tk_map/NSArray::tk_filter.
    [self measureBlock:^{
        NSArray *expected = array;

        NSMutableArray *mArray = [NSMutableArray new];

        TKTransduce(array.objectEnumerator, @[], TKMapping(^id(id val) {
            return val;
        }), ^id(id acc, id val) {
            [mArray addObject:val];
            return mArray;
        });

        NSArray *result = [mArray copy];

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceWithBigArrayMap
{
    NSArray *array = [self testArrayWithInts:10000];

    // Measure performance of standard impl.
    [self measureBlock:^{
        NSArray *expected = array;
        NSArray *result = [array tk_map:^id(id o) {
            return o;
        }];

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceWithBigArrayMutableArray
{
    NSArray *array = [self testArrayWithInts:10000];

    // Measure as a possible optimization in NSArray::tk_map/NSArray::tk_filter.
    [self measureBlock:^{
        NSArray *expected = array;

        NSMutableArray *mArray = [NSMutableArray new];

        TKTransduce(array.objectEnumerator, @[], TKMapping(^id(id val) {
            return val;
        }), ^id(id acc, id val) {
            [mArray addObject:val];
            return mArray;
        });

        NSArray *result = [mArray copy];

        XCTAssertEqualObjects(expected, result);
    }];
}

- (void)testPerformanceComposing
{
    NSArray *array = [self testArrayWithInts:10000];
    [self measureBlock:^{
        NSArray *transducers = @[
                TKMapping(^id(NSNumber *number) {
                    return [NSString stringWithFormat:@"%@", number];
                }),
                TKFiltering(^BOOL(NSString *str) {
                    return str.length < 4;
                }),
                TKMapping(^id(NSString *str) {
                    return @(str.intValue);
                })
        ];

        TKTransducer xform = TKComposeTransducersArray(transducers);

        TKTransduce(array.objectEnumerator, @[], xform, TKArrayAppendReducer());
    }];
}

- (void)testPerformanceChaining
{
    NSArray *array = [self testArrayWithInts:10000];

    [self measureBlock:^{
        [[[array tk_map:^id(NSNumber *number) {
            return [NSString stringWithFormat:@"%@", number];
        }] tk_filter:^BOOL(NSString *str) {
            return str.length < 4;
        }] tk_map:^id(NSString *str) {
            return @(str.intValue);
        }];
    }];
}

@end