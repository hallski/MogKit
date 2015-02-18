#import "NSArray+TransformationKit.h"


TKReducer TKArrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

TKReducer TKArrayAppendArrayReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObjectsFromArray:val];
    };
}

@implementation NSArray (TransformationKit)

- (instancetype)tk_map:(TKMapFunc)mapFunc
{
    return TKTransduce(self.objectEnumerator, @[], TKMapping(mapFunc), TKArrayAppendReducer());
}

- (instancetype)tk_filter:(TKPredicate)predicate
{
    return TKTransduce(self.objectEnumerator, @[], TKFiltering(predicate), TKArrayAppendReducer());
}

- (instancetype)tk_concat
{
    return TKReduce(self.objectEnumerator, @[], TKArrayAppendArrayReducer());
}

@end