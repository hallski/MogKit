//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MogKit.h"


@interface NSObjectExtensionTests : XCTestCase
@end

@implementation NSObjectExtensionTests

- (MOGTransformation)filterFastEnumFlattenAndAdd33
{
    return MOGComposeArray(
            @[
                    MOGFilter(^BOOL(id val) {
                        return [val conformsToProtocol:@protocol(NSFastEnumeration)];
                    }),
                    MOGFlatten(),
                    MOGMap(^id(NSNumber *number) {
                        return @(number.intValue + 33);
                    })
            ]);
}

- (void)testNSObjectTransformationWithArray
{
    id object = @[@1, @2, @3];
    NSArray *expected = @[@34, @35, @36];

    NSArray *result = [object mog_transform:[self filterFastEnumFlattenAndAdd33] reducer:MOGArrayReducer()];

    XCTAssertEqualObjects(expected, result);
}

- (void)testNSObjectTransformationWithNonArray
{
    id object = @1;
    NSArray *expected = @[];

    NSArray *result = [object mog_transform:[self filterFastEnumFlattenAndAdd33] reducer:MOGArrayReducer()];

    XCTAssertEqualObjects(expected, result);
}

- (void)testNSNumberToArray
{
    id object = @10;
    NSArray *expected = @[@(-10), @0, @10];

    NSArray *result = [object mog_transform:MOGFlatMap(^id(NSNumber *number) {
        return @[@(-number.intValue), @0, number];
    }) reducer:MOGArrayReducer()];

    XCTAssertEqualObjects(expected, result);
}

@end