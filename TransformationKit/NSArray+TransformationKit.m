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
    return [[self.objectEnumerator tk_transduce:TKMap(mapFunc)
                                        reducer:TKMutableArrayAppendReducer()
                                        initial:[NSMutableArray new]] copy];
}

- (instancetype)tk_filter:(TKPredicate)predicate
{
    return [[self.objectEnumerator tk_transduce:TKFilter(predicate)
                                        reducer:TKMutableArrayAppendReducer()
                                        initial:[NSMutableArray new]] copy];
}

- (instancetype)tk_concat
{
    return [[self.objectEnumerator tk_reduce:^id(NSMutableArray *acc, id val) {
        [acc addObjectsFromArray:val];
        return acc;
    } initial:[NSMutableArray new]] copy];
}

@end