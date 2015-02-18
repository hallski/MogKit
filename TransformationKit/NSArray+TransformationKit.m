#import "NSArray+TransformationKit.h"


TKReducer arrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

TKReducer arrayAppendArrayReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObjectsFromArray:val];
    };
}

@implementation NSArray (TransformationKit)

- (instancetype)tk_map:(TKMapFunc)mapFunc
{
    return TKTransduce(self.objectEnumerator, @[], TKMapping(mapFunc), arrayAppendReducer());
}

- (instancetype)tk_filter:(TKPredicate)predicate
{
    return TKTransduce(self.objectEnumerator, @[], TKFiltering(predicate), arrayAppendReducer());
}

- (instancetype)tk_concat
{
    return TKReduce(self.objectEnumerator, @[], arrayAppendArrayReducer());
}

@end