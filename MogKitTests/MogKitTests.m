//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MogKit.h"


@interface MogKitTests : XCTestCase
@end

@implementation MogKitTests

- (void)testEarlyTermination
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGReducer *reducer = MOGArrayReducer();
    reducer.reduce = ^id(NSMutableArray *acc, NSNumber *val) {
        [acc addObject:val];

        return val.intValue == 5 ? MOGReduced(acc) : acc;
    };

    NSArray *result = MOGTransduce(array, reducer, MOGIdentityTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testMap
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGMapTransducer(^id(NSNumber *number) {
            return @(number.intValue + 10);
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGMapTransducer(^id(id o) {
            return o;
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTransduceWithInitialValue
{
    NSArray *array = @[@1, @2, @3];
    NSArray *expected = @[@111, @222, @333, @11, @12, @13];

    NSMutableArray *initialArray = [NSMutableArray arrayWithArray:@[@111, @222, @333]];

    NSArray *result = MOGTransduceWithInitial(array, MOGArrayReducer(), initialArray,
                                              MOGMapTransducer(^id(NSNumber *val) {
                                                  return @(val.intValue + 10);
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testFilter
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGFilterTransducer(^BOOL(NSNumber *number) {
            int n = number.intValue;
            return n >= 10 && n <= 15;
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testRemove
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@1, @20];
    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGRemoveTransducer(^BOOL(NSNumber *number) {
            int n = number.intValue;
            return n >= 10 && n <= 15;
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTake
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGTakeTransducer(5));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeReuseTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGTransducer takingFive = MOGTakeTransducer(5);

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), takingFive);
    XCTAssertEqualObjects(expected, result);

    result = MOGTransduce(array, MOGArrayReducer(), takingFive);
    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGTakeWhileTransducer(^BOOL(NSNumber *number) {
            return number.intValue % 5 != 0;
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeNthTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @4, @7, @10];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGTakeNthTransducer(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@4, @5, @6, @7, @8, @9, @10];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGDropTransducer(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@5, @6, @7, @8, @9, @10];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGDropWhileTransducer(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGReplaceTransducer(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducerWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGReplaceTransducer(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceWithDefaultTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"-", @"c", @"-", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGReplaceWithDefaultTransducer(replacementDict, @"-"));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceWithDefaultTransducerWithNilAsDefault
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGReplaceWithDefaultTransducer(replacementDict, nil));

    XCTAssertEqualObjects(expected, result);
}


- (void)testKeepTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGKeepTransducer(^id(NSNumber *number) {
        return number.intValue % 2 == 0 ? nil : number;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepIndexedTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGKeepIndexedTransducer(^id(NSUInteger index, id o) {
        return index % 2 == 0 ? o : nil;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGUniqueTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testDedupeTransducer
{
    NSArray *array = @[@1, @2, @2, @3, @4, @4, @4, @5, @4, @1];
    NSArray *expected = @[@1, @2, @3, @4, @5, @4, @1];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGDedupeTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testCatTransducer
{
    NSArray *array = @[@[@1, @2], @[@3, @4, @5], @[@6]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGCatTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testCatWithMixOfNormalAndEnumerators
{
    NSArray *array = @[@1, @[@2, @3], @4, @5];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGCatTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapCatTransducer
{
    NSArray *array = @[@1, @2, @3];
    NSArray *expected = @[@1, @1, @1, @2, @2, @2, @3, @3, @3];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGMapCatTransducer(^id(id val) {
            return @[val, val, val];
        }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testCatTransducerWithEarlyTermination
{
    NSArray *array = @[@[@1, @2, @3], @[@4, @5, @6], @[@7, @8, @9, @10]];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGReducer *reducer = MOGArrayReducer();
    reducer.reduce = ^id(NSMutableArray *acc, NSNumber *val) {
        [acc addObject:val];

        return val.intValue == 5 ? MOGReduced(acc) : acc;
    };

    NSArray *result = MOGTransduce(array, reducer, MOGCatTransducer());

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitioningByTransducer
{
    NSArray *array = @[@1, @1, @2, @2, @3, @1];
    NSArray *expected = @[@[@1, @1], @[@2, @2], @[@3], @[@1]];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGPartitionByTransducer(^id(id val) {
        return val;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@[@1, @2], @[@3, @4], @[@5, @6], @[@7, @8], @[@9, @10]];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGPartitionTransducer(2));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGWindowTransducer(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGWindowTransducer(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), MOGWindowTransducer(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testLastValueReducer
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSNumber *expected = @5;

    NSNumber *result = MOGTransduce(array, MOGLastValueReducer(), MOGIdentityTransducer());

    XCTAssertEqualObjects(expected, result);
}

#pragma mark - Transducer composition
- (void)testComposeTwoTransducers
{
    NSArray *array = @[@1, @10, @100];
    NSArray *expected = @[@"10", @"100"];

    MOGTransducer xform = MOGCompose(
            MOGMapTransducer(^id(NSNumber *number) {
                return [NSString stringWithFormat:@"%@", number];
            }),
            MOGFilterTransducer(^BOOL(NSString *str) {
                return str.length >= 2;
            })
    );

    NSArray *result = MOGTransduce(array, MOGArrayReducer(), xform);

    XCTAssertEqualObjects(expected, result);
}

- (void)testComposeArrayOfTransducers
{
    NSArray *array = @[@50, @500, @5000, @50000];
    NSArray *expected = @[@50, @500];
    NSArray *transducers = @[
            MOGMapTransducer(^id(NSNumber *number) {
                return [NSString stringWithFormat:@"%@", number];
            }),
            MOGFilterTransducer(^BOOL(NSString *str) {
                return str.length < 4;
            }),
            MOGMapTransducer(^id(NSString *str) {
                return @(str.intValue);
            })
    ];
    MOGTransducer xform = MOGComposeArray(transducers);
    NSArray *result = MOGTransduce(array, MOGArrayReducer(), xform);

    XCTAssertEqualObjects(expected, result);
}

@end
