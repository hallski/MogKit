//
//  TransformationKit.m
//  TransformationKit
//
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "TransformationKit.h"


TKTransducer TKMap(id (^mapFunc)(id))
{
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

TKTransducer TKFilter(BOOL (^filterFunc)(id))
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

TKTransducer TKTake(int n)
{
    return ^TKReducer(TKReducer reducer) {
        __block int left = n;
        return ^id(id acc, id val) {
            return left-- > 0 ? reducer(acc, val) : acc;
        };
    };
}

TKTransducer TKTakeWhile(TKPredicate predicate)
{
    return ^TKReducer(TKReducer reducer) {
        __block BOOL keepTaking = YES;
        return ^id(id acc, id val) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            return keepTaking ? reducer(acc, val) : acc;
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
    return [transducers.reverseObjectEnumerator tk_reduce:^id(TKTransducer acc, TKTransducer val) {
        return TKComposeTransducers(acc, val);
    } initial:TKIdentityTransducer()];
}

id TKReduce(TKReducer reducer, id initial, id<TKEnumerable> source)
{
    id obj;
    id acc = initial;

    while ((obj = [source tk_nextValue])) {
        acc = reducer(acc, obj);
    }

    return acc;
}

id TKTransduce(TKTransducer transducer, TKReducer reducer, id initial, id<TKEnumerable> source)
{
    return TKReduce(transducer(reducer), initial, source);
}


@implementation NSEnumerator (TKTransformable)

- (id)tk_nextValue
{
    return [self nextObject];
}

- (id)tk_reduce:(TKReducer)reducer initial:(id)initial
{
    return TKReduce(reducer, initial, self);
}

- (id)tk_transduce:(TKTransducer)transducer reducer:(TKReducer)reducer initial:(id)initial
{
    return TKTransduce(transducer, reducer, initial, self);
}

@end
