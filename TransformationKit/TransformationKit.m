//
//  TransformationKit.m
//  TransformationKit
//
//  Created by Mikael Hallendal on 18/02/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "TransformationKit.h"


TKTransducer TKMapping(id (^mapFunc)(id)) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

TKTransducer TKFiltering(BOOL (^filterFunc)(id)) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return filterFunc(val) ? reducer(acc, val) : acc;
        };
    };
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

