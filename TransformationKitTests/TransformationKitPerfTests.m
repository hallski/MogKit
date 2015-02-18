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
    NSArray *array = [self testArrayWithInts:200000];

    [self measureBlock:^{
        NSArray *transducers = @[
                TKMapping(^id(NSNumber *number) { return @(number.intValue + 100); }),
                TKFiltering(^BOOL(NSNumber *number) { return number.intValue % 2 == 0; }),
                TKMapping(^id(NSNumber *number) { return [NSString stringWithFormat:@"%@", number]; })
        ];

        TKTransducer xform = TKComposeTransducersArray(transducers);

        NSMutableArray *mArray = [NSMutableArray new];
        TKTransduce(array.objectEnumerator, @[], xform, ^id(id acc, id val) {
            [mArray addObject:val];
            return mArray;
        });

        NSArray *result = [mArray copy];
        XCTAssertEqual(100000, [result count]);
    }];
}

- (void)testPerformanceChaining
{
    NSArray *array = [self testArrayWithInts:200000];

    [self measureBlock:^{
        NSArray *result = [[[array tk_map:^id(NSNumber *number) {
            return @(number.intValue + 100);
        }] tk_filter:^BOOL(NSNumber *number) {
            return number.intValue % 2 == 0;
        }] tk_map:^id(NSNumber *number) {
            return [NSString stringWithFormat:@"%@", number];
        }];

        XCTAssertEqual(100000, [result count]);
    }];
}

@end