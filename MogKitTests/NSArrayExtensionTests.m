#import <XCTest/XCTest.h>
#import <MogKit/MogKit.h>


@interface NSArrayExtensionTests : XCTestCase
@end

@implementation NSArrayExtensionTests

- (void)setUp
{
    [super setUp];

    // Setup code here.
}

- (void)tearDown
{
    // Tear-down code here.

    [super tearDown];
}

- (void)testArrayTransduce
{
    NSArray *array = @[@1, @2, @3, @4, @5];
    NSArray *expected = @[@101, @102, @103, @104, @105];

    NSArray *result = [array mog_transduce:MOGMap(^id(NSNumber *number) {
        return @(number.intValue + 100);
    })];

    XCTAssertEqualObjects(expected, result);
}

@end