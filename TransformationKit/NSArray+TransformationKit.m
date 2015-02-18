#import "NSArray+TransformationKit.h"


TKReducer TKArrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

TKReducer TKMutableArrayAppendReducer(void) {
    return ^id(NSMutableArray *acc, id val) {
        [acc addObject:val];
        return acc;
    };
}

@implementation NSArray (TransformationKit)

- (instancetype)tk_map:(TKMapFunc)mapFunc
{
    return [TKTransduce(TKMapping(mapFunc), TKMutableArrayAppendReducer(), [NSMutableArray new], self.objectEnumerator) copy];
}

- (instancetype)tk_filter:(TKPredicate)predicate
{
    return [TKTransduce(TKFiltering(predicate), TKMutableArrayAppendReducer(), [NSMutableArray new], self.objectEnumerator) copy];
}

- (instancetype)tk_concat
{
    return [TKReduce(^id(NSMutableArray *acc, id val) {
        [acc addObjectsFromArray:val];
        return acc;
    }, [NSMutableArray new], self.objectEnumerator) copy];
}

@end