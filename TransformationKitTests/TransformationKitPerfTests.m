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

- (void)testPerformanceComposing
{
    NSArray *array = [self testArrayWithInts:100000];

    [self measureBlock:^{
        NSArray *transducers = @[
                TKMapping(^id(NSNumber *number) { return @(number.intValue + 100); }),
                TKFiltering(^BOOL(NSNumber *number) { return YES; }),
                TKMapping(^id(NSNumber *number) { return @(number.intValue - 100); })
        ];

        TKTransducer xform = TKComposeTransducersArray(transducers);

        NSArray *result = TKTransduce(xform, TKMutableArrayAppendReducer(), [NSMutableArray new], array.objectEnumerator);

        XCTAssertEqualObjects(array, result);
    }];
}

- (void)testPerformanceChaining
{
    NSArray *array = [self testArrayWithInts:100000];

    [self measureBlock:^{
        NSArray *result = [[[array tk_map:^id(NSNumber *number) {
            return @(number.intValue + 100);
        }] tk_filter:^BOOL(NSNumber *number) {
            return YES;
        }] tk_map:^id(NSNumber *number) {
            return @(number.intValue - 100);
        }];

        XCTAssertEqualObjects(array, result);
    }];
}

@end