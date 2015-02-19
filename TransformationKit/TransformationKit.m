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

TKTransducer TKTaking(int n)
{
    return ^TKReducer(TKReducer reducer) {
        __block int left = n;
        return ^id(id acc, id val) {
            return left-- > 0 ? reducer(acc, val) : acc;
        };
    };
}

TKTransducer TKComposeTransducers(TKTransducer f, TKTransducer g)
{
    return ^TKReducer(TKReducer reducer) {
        return g(f(reducer));
    };
}

TKTransducer TKComposeTransducersArray(NSArray *transducers) {
    return TKReduce(^id(TKTransducer acc, TKTransducer val) {
            return TKComposeTransducers(acc, val);
        }, TKIdentityTransducer(), transducers.reverseObjectEnumerator);
}

id TKReduce(TKReducer reducer, id initial, NSEnumerator *source)
{
    id obj;
    id acc = initial;

    while ((obj = [source nextObject])) {
        acc = reducer(acc, obj);
    }

    return acc;
}

id TKTransduce(TKTransducer transducer, TKReducer reducer, id initial, NSEnumerator *source)
{
    return TKReduce(transducer(reducer), initial, source);
}

