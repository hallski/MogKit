#import "NSArray+TransformationKit.h"


TKReducer TKArrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

@implementation NSArray (TransformationKit)

- (instancetype)tk_map:(TKMapFunc)mapFunc
{
    // Using a mutable array to collect is done as an optimization to avoid creating new arrays for
    // each object.
    NSMutableArray *mArray = [NSMutableArray new];
    TKTransduce(self.objectEnumerator, @[], TKMapping(mapFunc), ^id(id acc, id val) {
        [mArray addObject:val];
        return mArray;
    });

    return [mArray copy];
}

- (instancetype)tk_filter:(TKPredicate)predicate
{
    // Using a mutable array to collect is done as an optimization to avoid creating new arrays for
    // each object.
    NSMutableArray *mArray = [NSMutableArray new];
    TKTransduce(self.objectEnumerator, @[], TKFiltering(predicate), ^id(id acc, id val) {
        [mArray addObject:val];
        return mArray;
    });

    return [mArray copy];
}

- (instancetype)tk_concat
{
    // Using a mutable array to collect is done as an optimization to avoid creating new arrays for
    // each object.
    NSMutableArray *mArray = [NSMutableArray new];
    TKReduce(self.objectEnumerator, @[], ^id(id acc, id val) {
        [mArray addObjectsFromArray:val];
        return mArray;
    });

    return [mArray copy];
}

@end