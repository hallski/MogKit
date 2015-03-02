#import <XCTest/XCTest.h>
#import "MogReduce.h"


@interface MogReduceTests : XCTestCase
@end

@implementation MogReduceTests

- (void)testArrayReducerInitialIsAMutableArray
{
    MOGReducer *reducer = MOGArrayReducer();

    NSMutableArray *mArray = reducer.initial();

    XCTAssert([mArray isKindOfClass:[NSMutableArray class]]);
}

- (void)testArrayReducerCompleteCreatesNonMutableCopy
{
    MOGReducer *reducer = MOGArrayReducer();
    NSMutableArray *mArray = [NSMutableArray arrayWithArray:@[@1, @2, @3, @4, @5]];

    NSArray *array = reducer.complete(mArray);

    XCTAssert([array isKindOfClass:[NSArray class]]);
    XCTAssertFalse([array isKindOfClass:[NSMutableArray class]]);
    XCTAssertEqualObjects(array, mArray);
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

@end