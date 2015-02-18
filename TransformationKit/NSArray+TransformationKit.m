#import "NSArray+TransformationKit.h"


TKReducer arrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

@implementation NSArray (TransformationKit)

- (NSArray *)tk_map:(TKMapFunc)mapFunc
{
    return transduce(self.objectEnumerator, @[], mapping(mapFunc), arrayAppendReducer());
}

- (NSArray *)tk_filter:(TKPredicate)predicate
{
    return transduce(self.objectEnumerator, @[], filtering(predicate), arrayAppendReducer());
}

@end