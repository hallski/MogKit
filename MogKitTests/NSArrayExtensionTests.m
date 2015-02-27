//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MogKit.h"


@interface NSArrayExtensionTests : XCTestCase
@end

@implementation NSArrayExtensionTests

- (void)testArrayTransduce
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@101, @102, @103, @104, @105];

    NSArray *result = [array mog_transform:MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 100);
    })];

    XCTAssertEqualObjects(expected, result);
}

- (void)testTransducedArrayFromEnumeration
{
    NSDictionary *dict = @{@"a": @1, @"b": @2, @"c": @3 };
    NSArray *expected = @[@"A", @"B", @"C"];

    NSArray *result = [NSArray mog_transformedArrayFromEnumeration:dict.keyEnumerator
                                                    transformation:MOGMap(^id(NSString *str) {
                                                        return [str uppercaseString];
                                                    })];

    XCTAssertEqualObjects(expected, result);
}


@end