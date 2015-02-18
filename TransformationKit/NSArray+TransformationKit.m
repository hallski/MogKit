#import "NSArray+TransformationKit.h"


TKReducer arrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

@implementation NSArray (TransformationKit)

- (NSArray *)tk_map:(TKMapFunc)mapFunc
{
    return TKTransduce(self.objectEnumerator, @[], TKMapping(mapFunc), arrayAppendReducer());
}

- (NSArray *)tk_filter:(TKPredicate)predicate
{
    return TKTransduce(self.objectEnumerator, @[], TKFiltering(predicate), arrayAppendReducer());
}

@end