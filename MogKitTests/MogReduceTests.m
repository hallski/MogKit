#import <XCTest/XCTest.h>
#import "MogReduce.h"


@interface MogReduceTests : XCTestCase
@end

@implementation MogReduceTests

- (void)testArrayReducerInitializeWithEmptyMutableArray
{
    MOGReducer *reducer = MOGArrayReducer();

    NSMutableArray *mArray = reducer.initial();
    NSArray *expected = @[];

    XCTAssert([mArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(expected, mArray);
}

- (void)testArrayReducerCompleteCreatesNonMutableCopy
{
    MOGReducer *reducer = MOGArrayReducer();
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5]];

    NSArray *result = reducer.complete(mArray);

    XCTAssert([result isKindOfClass:[NSArray class]]);
    XCTAssertFalse([result isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(result, mArray);
}

- (void)testArrayReducerReduceAddsObjects
{
    MOGReducer *reducer = MOGArrayReducer();

    NSMutableArray *mArray = reducer.initial();

    mArray = reducer.reduce(mArray, @1);
    mArray = reducer.reduce(mArray, @2);

    NSArray *expected = @[@1, @2];

    XCTAssertEqualObjects(expected, mArray);
}

- (void)testLastValueResolverReturnsVal
{
    MOGReducer *reducer = MOGLastValueReducer();

    id aString = @"aString";

    XCTAssertEqualObjects(@1, reducer.reduce(nil, @1));
    XCTAssertEqualObjects(aString, reducer.reduce(@123, aString));
}

- (void)testLastValueResolverDoesntChangeResultValue
{
    MOGReducer *reducer = MOGLastValueReducer();

    XCTAssertEqualObjects(@99, reducer.complete(@99));
}

- (void)testStringConcatReducerInitializeWithEmptyMutableString
{
    MOGReducer *reducer = MOGStringConcatReducer(nil);

    NSMutableString *mString = reducer.initial();
    NSString *expected = @"";

    XCTAssert([mString isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(expected, mString);
}

- (void)testStringConcatReducerCompleteCreatesNonMutableCopy
{
    MOGReducer *reducer = MOGStringConcatReducer(nil);

    NSMutableString *mString = [[NSMutableString alloc] initWithString:@"a string"];

    NSString *expected = @"a string";
    NSString *result = reducer.complete(mString);

    XCTAssert([result isKindOfClass:[NSString class]]);
    XCTAssertFalse([result isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(expected, result);
}

- (void)testStringConcatReducerReduceConcats
{
    MOGReducer *reducer = MOGStringConcatReducer(nil);

    NSMutableString *acc = reducer.initial();
    acc = reducer.reduce(acc, @"abc");
    acc = reducer.reduce(acc, @"def");

    NSString *expected = @"abcdef";

    XCTAssertEqualObjects(expected, acc);
}

- (void)testStringConcatReducerSupportsSeparator
{
    MOGReducer *reducer = MOGStringConcatReducer(@", ");

    NSMutableString *acc = reducer.initial();
    acc = reducer.reduce(acc, @"part 1");
    acc = reducer.reduce(acc, @"part 2");

    NSString *expected = @"part 1, part 2";

    XCTAssertEqualObjects(expected, acc);
}

@end