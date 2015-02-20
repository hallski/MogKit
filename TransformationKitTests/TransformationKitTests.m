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

- (void)testMap
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = TKTransduce(TKMap(^id(NSNumber *number) {
        return @(number.intValue + 10);
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = TKTransduce(TKMap(^id(id o) {
        return o;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testFilter
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = TKTransduce(TKFilter(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testRemove
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@1, @20];
    NSArray *result = TKTransduce(TKRemove(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTake
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = TKTransduce(TKTake(5), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeReuseTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    TKTransducer takingFive = TKTake(5);

    NSArray *result = TKTransduce(takingFive, TKArrayAppendReducer(), @[], array.objectEnumerator);
    XCTAssertEqualObjects(expected, result);

    result = TKTransduce(takingFive, TKArrayAppendReducer(), @[], array.objectEnumerator);
    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4];

    NSArray *result = TKTransduce(TKTakeWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeNthTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @4, @7, @10];

    NSArray *result = TKTransduce(TKTakeNth(3), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@4, @5, @6, @7, @8, @9, @10];

    NSArray *result = TKTransduce(TKDrop(3), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@5, @6, @7, @8, @9, @10];

    NSArray *result = TKTransduce(TKDropWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = TKTransduce(TKReplace(replacementDict), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducerWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = TKTransduce(TKReplace(replacementDict), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = TKTransduce(TKKeep(^id(NSNumber *number) {
        return number.intValue % 2 == 0 ? nil : number;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepIndexedTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = TKTransduce(TKKeepIndexed(^id(int index, id o) {
        return index % 2 == 0 ? o : nil;
    }), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = TKTransduce(TKUnique(), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = TKTransduce(TKWindowed(3), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = TKTransduce(TKWindowed(3), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = TKTransduce(TKWindowed(3), TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}


#pragma mark - Transducer composition
- (void)testComposeTwoTransducers
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6];
    NSArray *expected = @[@6, @12, @18];
    TKTransducer xform = TKComposeTransducers(
            TKMap(^id(NSNumber *number) {
                return @(number.intValue * 3);
            }),
            TKFilter(^BOOL(NSNumber *number) {
                return number.intValue % 2 == 0;
            })
    );

    NSArray *result = TKTransduce(xform, TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}

- (void)testComposeArrayOfTransducers
{
    NSArray *array = @[@50, @500, @5000, @50000];
    NSArray *expected = @[@50, @500];
    NSArray *transducers = @[
            TKMap(^id(NSNumber *number) {
                return [NSString stringWithFormat:@"%@", number];
            }),
            TKFilter(^BOOL(NSString *str) {
                return str.length < 4;
            }),
            TKMap(^id(NSString *str) {
                return @(str.intValue);
            })
    ];
    TKTransducer xform = TKComposeTransducersArray(transducers);
    NSArray *result = TKTransduce(xform, TKArrayAppendReducer(), @[], array.objectEnumerator);

    XCTAssertEqualObjects(expected, result);
}


// Can this be made general?
- (void)testArrayFlatten
{
    NSArray *array = @[@[@1, @2, @3], @[@4, @5, @6], @[@7, @8, @9]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6, @7, @8, @9];
    NSArray *result = [array tk_concat];

    XCTAssertEqualObjects(expected, result);
}

@end
