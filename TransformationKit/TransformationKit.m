//
//  TransformationKit.m
//  TransformationKit
//
//  Created by Mikael Hallendal on 18/02/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "TransformationKit.h"


TKTransducer mapping(id (^mapFunc)(id)) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

TKTransducer filtering(BOOL (^filterFunc)(id)) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return filterFunc(val) ? reducer(acc, val) : acc;
        };
    };
}


id reduce(NSEnumerator *source, id initial, TKReducer reducer)
{
    id obj;
    id acc = initial;

    while ((obj = [source nextObject])) {
        acc = reducer(acc, obj);
    }

    return acc;
}


TKReducer arrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

id transduce(NSEnumerator *source, id initial, TKTransducer transducer, TKReducer reducer)
{
    return reduce(source, initial, transducer(reducer));
}

@implementation NSArray (TransformKit)

- (NSArray *)tk_map:(TKMapFunc)mapFunc
{
    return transduce(self.objectEnumerator, @[], mapping(mapFunc), arrayAppendReducer());
}

- (NSArray *)tk_filter:(TKPredicate)predicate
{
    return transduce(self.objectEnumerator, @[], filtering(predicate), arrayAppendReducer());
}

@end