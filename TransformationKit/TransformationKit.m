//
//  TransformationKit.m
//  TransformationKit
//
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "TransformationKit.h"


TKTransducer TKMapping(id (^mapFunc)(id))
{
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

TKTransducer TKFiltering(BOOL (^filterFunc)(id))
{
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return filterFunc(val) ? reducer(acc, val) : acc;
        };
    };
}


TKTransducer TKIdentityTransducer() {
    return ^TKReducer(TKReducer reducer) {
        return reducer;
    };
}

TKTransducer TKCompose(TKTransducer f, TKTransducer g)
{
    return ^TKReducer(TKReducer reducer) {
        return g(f(reducer));
    };
}

TKTransducer TKComposeArray(NSArray *transducers) {
    return TKReduce(transducers.reverseObjectEnumerator, TKIdentityTransducer(), ^id(TKTransducer acc, TKTransducer val) {
        return TKCompose(acc, val);
    });
}

id TKReduce(NSEnumerator *source, id initial, TKReducer reducer)
{
    id obj;
    id acc = initial;

    while ((obj = [source nextObject])) {
        acc = reducer(acc, obj);
    }

    return acc;
}

id TKTransduce(NSEnumerator *source, id initial, TKTransducer transducer, TKReducer reducer)
{
    return TKReduce(source, initial, transducer(reducer));
}

