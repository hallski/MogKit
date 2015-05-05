//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

import Foundation
import MogKit
import XCTest

class TransformationTests : XCTestCase {

    func testEarlyTermination() {
        // TODO: Implement
    }
    func testMap() {
        let array = [1, 2, 3, 4]
        let expected = [11, 12, 13, 14]

        let map = Map({ $0 + 10 }).transduce { $0 + [$1] }
        
        let result = reduce(array, [], map)

        XCTAssertEqual(result, expected)
    }
    
    func testMapEmptyArray() {
        let array = []
        let expected = []
        
        let result = reduce(array, [], Map({ $0 }).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }
    
    func testTransformWithEmptyValue() {
        let array = [1, 2, 3]
        let expected = [111, 222, 333, 11, 12, 13]
        
        let result = reduce(array, [111, 222, 333], Map({ $0 + 10 }).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

    func testFilter() {
        let array = [1, 10, 15, 20]
        let expected = [10, 15]
        
        let filter = Filter({ $0 >= 10 && $0 <= 15}).transduce { $0 + [$1] }
        let result = reduce(array, [], filter)
        
        XCTAssertEqual(result, expected)
    }
    
    func testRemove() {
        let array = [1, 10, 15, 20]
        let expected = [1, 20]
        
        let result = reduce(array, [], Remove({ $0 >= 10 && $0 <= 15}).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }
    
    func testTake() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [1, 2, 3, 4, 5]
        
        let result = reduce(array, [], Take(5).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }
    
    func testTakeWithZero() {
        let array = [1, 2]
        let expected = []
        
        let result = reduce(array, [], Take(0).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

    func testTakeReuse() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [1, 2, 3, 4, 5]
        
        let takeFive = Take<Int>(5)
        
        var result = reduce(array, [], takeFive.transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
        
        result = reduce(array, [], takeFive.transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }

    func testTakeWithStop() {
        // TODO: Implement
    }
    
    func testTakeWhile() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [1, 2, 3, 4]
        
        let result = reduce(array, [], TakeWhile({ $0 % 5 != 0 }).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }

    func testTakeWhileWithNULLStop() {
        // TODO: Implement
    }
    
    func testTakeNth() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [1, 4, 7, 10]
        
        let result = reduce(array, [], TakeNth(3).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }

    func testDrop() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [4, 5, 6, 7, 8, 9, 10]
        
        let result = reduce(array, [], Drop(3).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }
    
    func testDropWhile() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [5, 6, 7, 8, 9, 10]
        
        let result = reduce(array, [], DropWhile({$0 % 5 != 0}).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }

    func testDropNil() {
        let array = [1, 2, 3, 4, 5]
        let expected = [1, 3, 5]
        
        let map = Map { (val: Int) -> Optional<Int> in
            return val % 2 == 0 ? nil : val
        }
        let xform = map |> DropNil()
        
        let result = reduce(array, [], xform.transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

/*
    func testReplace() {
        let array = [1, 2, 3, 4, 5]
        let expected = ["a", "b", "c", "d", "e"]

        let replacements = [1: "a", 2: "b", 3: "c", 4: "d", 5: "e"]

        let result = reduce(array, [], Replace(replacements, fallBack: "-").transduce { $0 + [$1] })

        XCTAssertEqual(result, expected)
    }
- (void)testReplaceTransformation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"b", @"c", @"d", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"2": @"b", @"3" : @"c", @"4" : @"d", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}

*/
    // Insert point
/*
- (void)testReplaceTransformationWithMissingTranslation
{
    NSArray *array = @[@"1", @"2", @"3", @"4", @"5"];
    NSArray *expected = @[@"a", @"2", @"c", @"4", @"e"];

    NSDictionary *replacementDict = @{ @"1" : @"a", @"3" : @"c", @"5" : @"e" };

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGReplace(replacementDict));

    XCTAssertEqualObjects(expected, result);
}
*/
    func testReplaceWithDefault() {
        let array = [1, 2, 3, 4, 5]
        let expected = ["a", "-", "c", "-", "e"]

        let replacements = [1: "a", 3: "c", 5: "e"]

        let result = reduce(array, [], Replace(replacements, fallBack: "-").transduce {$0 + [$1] })

        XCTAssertEqual(result, expected)
    }
/*

- (void)testKeepTransformation
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@11, @13, @15, @17, @19];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGMapDropNil(^id(NSNumber *number) {
        return number.intValue % 2 == 0 ? nil : @(number.intValue + 10);
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testUniqueTransformation
{
    NSArray *array = @[@1, @2, @3, @4, @3, @2, @1, @8, @9, @10];
    NSArray *expected = @[@1, @2, @3, @4, @8, @9, @10];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGUnique());

    XCTAssertEqualObjects(expected, result);
}

- (void)testDedupeTransformation
{
    NSArray *array = @[@1, @2, @2, @3, @4, @4, @4, @5, @4, @1];
    NSArray *expected = @[@1, @2, @3, @4, @5, @4, @1];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGDedupe());

    XCTAssertEqualObjects(expected, result);
}

- (void)testFlattenTransformation
{
    NSArray *array = @[@[@1, @2], @[@3, @4, @5], @[@6]];
    NSArray *expected = @[@1, @2, @3, @4, @5, @6];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGFlatten());

    XCTAssertEqualObjects(expected, result);
}

- (void)testFlattenWithMixOfNormalAndEnumerators
{
    NSArray *array = @[@1, @[@2, @3], @4, @5];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGFlatten());

    XCTAssertEqualObjects(expected, result);
}

- (void)testFlattenWithNULLStop
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@1, @2];

    MOGReducer *arrayReducer = MOGArrayReducer();
    MOGReducer *reducer = MOGFlatten()(arrayReducer);

    XCTAssertEqualObjects(expected, reducer.reduce(arrayReducer.initial(), array, NULL));
}

- (void)testFlatMapTransformation
{
    NSArray *array = @[@1, @2, @3];
    NSArray *expected = @[@1, @1, @1, @2, @2, @2, @3, @3, @3];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGFlatMap(^id(id val) {
        return @[val, val, val];
    }));

    XCTAssertEqualObjects(expected, result);
}

- (void)testFlattenTransformationWithEarlyTermination
{
    NSArray *array = @[@[@1, @2, @3], @[@4, @5, @6], @[@7, @8, @9, @10]];
    NSArray *expected = @[@1, @2, @3, @4, @5];

    MOGReducer *reducer = MOGArrayReducer();
    reducer.reduce = ^id(NSMutableArray *acc, NSNumber *val, BOOL *stop) {
        [acc addObject:val];

        *stop = val.intValue == 5;

        return acc;
    };

    NSArray *result = MOGTransform(array, reducer, MOGFlatten());

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitioningByTransformation
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

- (void)testPartitionByWithNULLStop
{
    MOGReducer *reducer = MOGPartitionBy(^id(NSNumber *val) {
        return @(val.intValue % 2 == 0);
    })(MOGLastValueReducer());

    XCTAssertEqualObjects(@[], reducer.reduce(@[], @1, NULL));
    XCTAssertEqualObjects(@[@1], reducer.reduce(@[], @2, NULL));
}

- (void)testPartitionTransformation
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8, @9, @10];
    NSArray *expected = @[@[@1, @2], @[@3, @4], @[@5, @6], @[@7, @8], @[@9, @10]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGPartition(2));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionWithNonFinishedPartition
{
    NSArray *array = @[@1, @2, @3, @4, @5, @6, @7, @8];
    NSArray *expected = @[@[@1, @2, @3], @[@4, @5, @6], @[@7, @8]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGPartition(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testPartitionWithEarlyTermination
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @2], @[@3, @4]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGCompose(MOGPartition(2), MOGTake(2)));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransformationWithOneValue
{
    NSArray *array = @[@1];
    NSArray *expected = @[@[@1, @1, @1]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransformationWithTwoValues
{
    NSArray *array = @[@1, @2];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}

- (void)testWindowedTransformationWithMoreValuesThanWindowSize
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@[@1, @1, @1], @[@1, @1, @2], @[@1, @2, @3], @[@2, @3, @4], @[@3, @4, @5]];

    NSArray *result = MOGTransform(array, MOGArrayReducer(), MOGWindow(3));

    XCTAssertEqualObjects(expected, result);
}


#pragma mark - Transformation composition
- (void)testComposeTwoTransformations
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

- (void)testComposeArrayOfTransformations
{
    NSArray *array = @[@50, @500, @5000, @50000];
    NSArray *expected = @[@50, @500];
    NSArray *transformations = @[
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

    MOGTransformation xform = MOGComposeArray(transformations);
    NSArray *result = MOGTransform(array, MOGArrayReducer(), xform);

    XCTAssertEqualObjects(expected, result);
}

- (void)testTransformer
{
    MOGMapFunc add10 = MOGValueTransformer(MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 10);
    }));

    XCTAssertEqualObjects(@10, add10(@0));
    XCTAssertEqualObjects(@11, add10(@1));
}

- (void)testTransformerWithTerminatedTransformation
{
    MOGMapFunc add10TerminateAfter2 = MOGValueTransformer(MOGCompose(MOGTake(2), MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 10);
    })));

    XCTAssertEqualObjects(@10, add10TerminateAfter2(@0));
    XCTAssertEqualObjects(@11, add10TerminateAfter2(@1));
    XCTAssertNil(add10TerminateAfter2(@2));
    XCTAssertNil(add10TerminateAfter2(@3));
}
*/
    func testComposition() {
        let array = [1, 10, 100]
        let expected = ["10", "100"]
        
        let m = Map{ (val: Int) in return String(val) }
        let f = Filter { (val: String) in return count(val) >= 2 }
        
        let xform = m |> f
        let result = reduce(array, [], xform.transduce({ $0 + [$1] }))
        
        XCTAssertEqual(result, expected)
    }
    
    func testCompositionMultiple() {
        let array = [50, 500, 5000, 50000]
        let expected = [50, 500]
        
        let xform = Map { (val: Int) in String(val) } |> Filter { (val: String) in count(val) < 4 } |> Map { (val: String) in val.toInt() } |> DropNil()
        
        let result = reduce(array, [], xform.transduce({ $0 + [$1] }))
        XCTAssertEqual(result, expected)
    }
}





