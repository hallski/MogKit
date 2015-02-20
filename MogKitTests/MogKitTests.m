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

- (void)testMap
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGMap(^id(NSNumber *number) {
                                                  return @(number.intValue + 10);
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGMap(^id(id o) {
                                                  return o;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testFilter
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGFilter(^BOOL(NSNumber *number) {
                                                  int n = number.intValue;
                                                  return n >= 10 && n <= 15;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testRemove
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@1, @20];
    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGRemove(^BOOL(NSNumber *number) {
                                                  int n = number.intValue;
                                                  return n >= 10 && n <= 15;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTake
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGTake(5));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeReuseTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGTransducer takingFive = MOGTake(5);

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], takingFive);
    XCTAssertEqualObjects(expected, result);

    result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], takingFive);
    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGTakeWhile(^BOOL(NSNumber *number) {
                                                  return number.intValue % 5 != 0;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeNthTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @4, @7, @10];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGTakeNth(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@4, @5, @6, @7, @8, @9, @10];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGDrop(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@5, @6, @7, @8, @9, @10];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGDropWhile(^BOOL(NSNumber *number) {
                                                  return number.intValue % 5 != 0;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducerWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGKeep(^id(NSNumber *number) {
                                                  return number.intValue % 2 == 0 ? nil : number;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepIndexedTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[],
                                              MOGKeepIndexed(^id(int index, id o) {
                                                  return index % 2 == 0 ? o : nil;
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGUnique());

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGWindowed(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGWindowed(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], MOGWindowed(3));

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

    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], xform);

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
    NSArray *result = MOGEnumerationTransduce(array, MOGArrayAppendReducer(), @[], xform);

    XCTAssertEqualObjects(expected, result);
}

@end
