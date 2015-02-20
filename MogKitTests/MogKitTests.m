//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MogKit.h"
#import "NSEnumerator+MogKit.h"


@interface MogKitTests : XCTestCase

@end

@implementation MogKitTests

- (void)testMap
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = MOGEnumerableTransduce(MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 10);
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = MOGEnumerableTransduce(MOGMap(^id(id o) {
        return o;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testFilter
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = MOGEnumerableTransduce(MOGFilter(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testRemove
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@1, @20];
    NSArray *result = MOGEnumerableTransduce(MOGRemove(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTake
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGEnumerableTransduce(MOGTake(5), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeReuseTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGTransducer takingFive = MOGTake(5);

    NSArray *result = MOGEnumerableTransduce(takingFive, MOGArrayAppendReducer(), @[], array.objectEnumerator);
    XCTAssertEqualObjects(expected, result);

    result = MOGEnumerableTransduce(takingFive, MOGArrayAppendReducer(), @[], array.objectEnumerator);
    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4];

    NSArray *result = MOGEnumerableTransduce(MOGTakeWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeNthTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @4, @7, @10];

    NSArray *result = MOGEnumerableTransduce(MOGTakeNth(3), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@4, @5, @6, @7, @8, @9, @10];

    NSArray *result = MOGEnumerableTransduce(MOGDrop(3), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@5, @6, @7, @8, @9, @10];

    NSArray *result = MOGEnumerableTransduce(MOGDropWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = MOGEnumerableTransduce(MOGReplace(replacementDict), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducerWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGEnumerableTransduce(MOGReplace(replacementDict), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGEnumerableTransduce(MOGKeep(^id(NSNumber *number) {
        return number.intValue % 2 == 0 ? nil : number;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepIndexedTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGEnumerableTransduce(MOGKeepIndexed(^id(int index, id o) {
        return index % 2 == 0 ? o : nil;
    }), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = MOGEnumerableTransduce(MOGUnique(), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = MOGEnumerableTransduce(MOGWindowed(3), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = MOGEnumerableTransduce(MOGWindowed(3), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = MOGEnumerableTransduce(MOGWindowed(3), MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}


#pragma mark - Transducer composition
- (void)testComposeTwoTransducers
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    NSArray *expected = @[@6, @12, @18];
    MOGTransducer xform = MOGComposeTransducers(
            MOGMap(^id(NSNumber *number) {
                return @(number.intValue * 3);
            }),
            MOGFilter(^BOOL(NSNumber *number) {
                return number.intValue % 2 == 0;
            })
    );

    NSArray *result = MOGEnumerableTransduce(xform, MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testComposeArrayOfTransducers
{
    NSArray *array = @[@50, @500, @5000, @50000];
    NSArray *expected = @[@50, @500];
    NSArray *transducers = @[
            MOGMap(^id(NSNumber *number) {
                return [NSString stringWithFormat:@"%@", number];
            }),
            MOGFilter(^BOOL(NSString *str) {
                return str.length < 4;
            }),
            MOGMap(^id(NSString *str) {
                return @(str.intValue);
            })
    ];
    MOGTransducer xform = MOGComposeTransducersArray(transducers);
    NSArray *result = MOGEnumerableTransduce(xform, MOGArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

@end
