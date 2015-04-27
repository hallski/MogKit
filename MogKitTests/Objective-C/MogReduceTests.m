#import <XCTest/XCTest.h>
#import "MogReduce.h"


@interface MogReduceTests : XCTestCase
@end

@implementation MogReduceTests

- (void)testSimpleReducer
{
    MOGReducer *reducer = MOGSimpleReducer(^id(id acc, id val, BOOL *stop) {
        return val;
    });

    XCTAssertNil(reducer.initial());
    XCTAssertEqualObjects(@1, reducer.reduce(nil, @1, NULL));
    XCTAssertEqualObjects(@"a", reducer.complete(@"a"));
}

- (void)testArrayReducerInitializeWithEmptyMutableArray
{
    MOGReducer *reducer = MOGArrayReducer();

    NSMutableArray *mArray = reducer.initial();
    NSArray *expected = @[];

    XCTAssert([mArray isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(expected, mArray);
}

- (void)testArrayReducerCompleteCompleteDoesntChangeTheValues
{
    MOGReducer *reducer = MOGArrayReducer();
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5]];

    NSArray *result = reducer.complete(mArray);

    XCTAssert([result isKindOfClass:[NSArray class]]);
    XCTAssertEqualObjects(result, mArray);
}

- (void)testArrayReducerReduceAddsObjects
{
    MOGReducer *reducer = MOGArrayReducer();

    NSMutableArray *mArray = reducer.initial();
    BOOL stop = NO;

    mArray = reducer.reduce(mArray, @1, &stop);
    mArray = reducer.reduce(mArray, @2, &stop);

    NSArray *expected = @[@1, @2];

    XCTAssertEqualObjects(expected, mArray);
}

- (void)testLastValueResolverReturnsVal
{
    MOGReducer *reducer = MOGLastValueReducer();

    id aString = @"aString";
    BOOL stop = NO;

    XCTAssertEqualObjects(@1, reducer.reduce(nil, @1, &stop));
    XCTAssertEqualObjects(aString, reducer.reduce(@123, aString, &stop));
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

- (void)testStringConcatReducerCompleteDoesntChangeTheValues
{
    MOGReducer *reducer = MOGStringConcatReducer(nil);

    NSMutableString *mString = [[NSMutableString alloc] initWithString:@"a string"];

    NSString *expected = @"a string";
    NSString *result = reducer.complete(mString);

    XCTAssert([result isKindOfClass:[NSString class]]);
    XCTAssertEqualObjects(expected, result);
}

- (void)testStringConcatReducerReduceConcats
{
    MOGReducer *reducer = MOGStringConcatReducer(nil);

    NSMutableString *acc = reducer.initial();
    BOOL stop = NO;

    acc = reducer.reduce(acc, @"abc", &stop);
    acc = reducer.reduce(acc, @"def", &stop);

    NSString *expected = @"abcdef";

    XCTAssertEqualObjects(expected, acc);
}

- (void)testStringConcatReducerSupportsSeparator
{
    MOGReducer *reducer = MOGStringConcatReducer(@", ");

    NSMutableString *acc = reducer.initial();
    BOOL stop = NO;

    acc = reducer.reduce(acc, @"part 1", &stop);
    acc = reducer.reduce(acc, @"part 2", &stop);

    NSString *expected = @"part 1, part 2";

    XCTAssertEqualObjects(expected, acc);
}

@end