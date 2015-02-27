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

    NSArray *result = MOGTransform(array, reducer, MOGIdentity());

    XCTAssertEqualObjects(expected, result);
}

- (void)testMap
{
    NSArray *array = @[@1, @2, @3, @4];
    NSArray *expected = @[@11, @12, @13, @14];
    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 10);
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapEmptyArray
{
    NSArray *array = @[];
    NSArray *expected = @[];
    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGMap(^id(id o) {
        return o;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTransduceWithInitialValue
{
    NSArray *array = @[@1, @2, @3];
    NSArray *expected = @[@111, @222, @333, @11, @12, @13];

    NSMutableArray *initialArray = [NSMutableArray arrayWithArray:@[@111, @222, @333]];

    NSArray *result = MOGTransformWithInitial(array, MOGArrayReducer(), initialArray,
                                              MOGMap(^id(NSNumber *val) {
                                                  return @(val.intValue + 10);
                                              }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testFilter
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@10, @15];
    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGFilter(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testRemove
{
    NSArray *array = @[@1, @10, @15, @20];
    NSArray *expected = @[@1, @20];
    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGRemove(^BOOL(NSNumber *number) {
        int n = number.intValue;
        return n >= 10 && n <= 15;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTake
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGTake(5));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeReuseTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGTransformation takingFive = MOGTake(5);

    NSArray *result = MOGTransform(array, MOGArrayReducer(), takingFive);
    XCTAssertEqualObjects(expected, result);

    result = MOGTransform(array, MOGArrayReducer(), takingFive);
    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGTakeWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testTakeNthTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @4, @7, @10];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGTakeNth(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@4, @5, @6, @7, @8, @9, @10];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGDrop(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testDropWhileTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@5, @6, @7, @8, @9, @10];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGDropWhile(^BOOL(NSNumber *number) {
        return number.intValue % 5 != 0;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceTransducerWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceWithDefaultTransducer
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"-", @"c", @"-", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplaceWithDefault(replacementDict, @"-"));

    XCTAssertEqualObjects(expected, result);
}

- (void)testReplaceWithDefaultTransducerWithNilAsDefault
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplaceWithDefault(replacementDict, nil));

    XCTAssertEqualObjects(expected, result);
}


- (void)testKeepTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGKeep(^id(NSNumber *number) {
        return number.intValue % 2 == 0 ? nil : number;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testKeepIndexedTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@1, @3, @5, @7, @9];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGKeepIndexed(^id(NSUInteger index, id o) {
        return index % 2 == 0 ? o : nil;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGUnique());

    XCTAssertEqualObjects(expected, result);
}

- (void)testDedupeTransducer
{
    NSArray *array = @[@1, @2, @2, @3, @4, @4, @4, @5, @4, @1];
    NSArray *expected = @[@1, @2, @3, @4, @5, @4, @1];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGDedupe());

    XCTAssertEqualObjects(expected, result);
}

- (void)testCatTransducer
{
    NSArray *array = @[@[@1, @2], @[@3, @4, @5], @[@6]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGCat());

    XCTAssertEqualObjects(expected, result);
}

- (void)testCatWithMixOfNormalAndEnumerators
{
    NSArray *array = @[@1, @[@2, @3], @4, @5];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGCat());

    XCTAssertEqualObjects(expected, result);
}

- (void)testMapCatTransducer
{
    NSArray *array = @[@1, @2, @3];
    NSArray *expected = @[@1, @1, @1, @2, @2, @2, @3, @3, @3];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGMapCat(^id(id val) {
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

    NSArray *result = MOGTransform(array, reducer, MOGCat());

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitioningByTransducer
{
    NSArray *array = @[@1, @1, @2, @2, @3, @1];
    NSArray *expected = @[@[@1, @1], @[@2, @2], @[@3], @[@1]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGPartitionBy(^id(id val) {
        return val;
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionByWithEarlyTermination
{
    NSArray *array = @[@1, @1, @2, @2, @3];
    NSArray *expected = @[@[@1, @1], @[@2, @2]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGCompose(MOGPartitionBy(^id(id val) {
        return val;
    }), MOGTake(2)));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionTransducer
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@[@1, @2], @[@3, @4], @[@5, @6], @[@7, @8], @[@9, @10]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGPartition(2));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionWithEarlyTermination
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @2], @[@3, @4]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGCompose(MOGPartition(2), MOGTake(2)));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransducerWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testLastValueReducer
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSNumber *expected = @5;

    NSNumber *result = MOGTransform(array, MOGLastValueReducer(), MOGIdentity());

    XCTAssertEqualObjects(expected, result);
}

#pragma mark - Transducer composition
- (void)testComposeTwoTransducers
{
    NSArray *array = @[@1, @10, @100];
    NSArray *expected = @[@"10", @"100"];

    MOGTransformation xform = MOGCompose(
            MOGMap(^id(NSNumber *number) {
                return [NSString stringWithFormat:@"%@", number];
            }),
            MOGFilter(^BOOL(NSString *str) {
                return str.length >= 2;
            })
    );

    NSArray *result = MOGTransform(array, MOGArrayReducer(), xform);

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
    MOGTransformation xform = MOGComposeArray(transducers);
    NSArray *result = MOGTransform(array, MOGArrayReducer(), xform);

    XCTAssertEqualObjects(expected, result);
}

@end
