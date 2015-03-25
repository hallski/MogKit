#import <XCTest/XCTest.h>
#import "MogReduce.h"


@interface MogReduceTests : XCTestCase
@end

@implementation MogReduceTests

- (void)testArrayReducerInitializeWithEmptyMutableArray
{
    MOGReducer reducer = MOGArrayReducer();

    NSMutableArray *mArray = [NSMutableArray new];
    NSArray *expected = @[];

    XCTAssert([mArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(expected, mArray);
}


- (void)testArrayReducerReduceAddsObjects
{
    MOGReducer reducer = MOGArrayReducer();

    NSMutableArray *mArray = [NSMutableArray new];

    mArray = reducer(mArray, @1);
    mArray = reducer(mArray, @2);

    NSArray *expected = @[@1, @2];

    XCTAssertEqualObjects(expected, mArray);
}

- (void)testLastValueResolverReturnsVal
{
    MOGReducer reducer = MOGLastValueReducer();

    id aString = @"aString";

    XCTAssertEqualObjects(@1, reducer(nil, @1));
    XCTAssertEqualObjects(aString, reducer(@123, aString));
}

- (void)testStringConcatReducerInitializeWithEmptyMutableString
{
    MOGReducer reducer = MOGStringConcatReducer(nil);

    NSMutableString *mString = [NSMutableString new];
    NSString *expected = @"";

    XCTAssert([mString isKindOfClass:[NSMutableString class]]);
    XCTAssertEqualObjects(expected, mString);
}

- (void)testStringConcatReducerReduceConcats
{
    MOGReducer reducer = MOGStringConcatReducer(nil);

    NSMutableString *acc = [NSMutableString new];
    acc = reducer(acc, @"abc");
    acc = reducer(acc, @"def");

    NSString *expected = @"abcdef";

    XCTAssertEqualObjects(expected, acc);
}

- (void)testStringConcatReducerSupportsSeparator
{
    MOGReducer reducer = MOGStringConcatReducer(@", ");

    NSMutableString *acc = [NSMutableString new];
    acc = reducer(acc, @"part 1");
    acc = reducer(acc, @"part 2");

    NSString *expected = @"part 1, part 2";

    XCTAssertEqualObjects(expected, acc);
}

@end