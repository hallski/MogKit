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

TKTransducer TKFilter(TKPredicate predicate)
{
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return predicate(val) ? reducer(acc, val) : acc;
        };
    };
}


TKTransducer TKRemove(TKPredicate predicate) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return predicate(val) ? acc : reducer(acc, val);
        };
    };
}

TKTransducer TKIdentity() {
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

TKTransducer TKTakeNth(int n) {
    return ^TKReducer(TKReducer reducer) {
        __block int i = 0;
        return ^id(id acc, id val) {
            return (i++ % n == 0) ? reducer(acc, val) : acc;
        };
    };
}

TKTransducer TKDrop(int n) {
    return ^TKReducer(TKReducer reducer) {
        __block int dropped = 0;
        return ^id(id acc, id val) {
            if (dropped < n) {
                dropped++;
                return acc;
            }

            return reducer(acc, val);
        };
    };
}

TKTransducer TKDropWhile(TKPredicate predicate) {
    return ^TKReducer(TKReducer reducer) {
        __block BOOL keepDropping = YES;
        return ^id(id acc, id val) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer(acc, val);
        };
    };
}

TKTransducer TKReplace(NSDictionary *replacements) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            val = replacements[val] ?: val;

            return reducer(acc, val);
        };
    };
}

TKTransducer TKKeep(TKMapFunc func) {
    return ^TKReducer(TKReducer reducer) {
        return ^id(id acc, id val) {
            return func(val) == nil ? acc : reducer(acc, val);
        };
    };
}

TKTransducer TKKeepIndexed(TKIndexedMapFunc indexedMapFunc) {
    return ^TKReducer(TKReducer reducer) {
        __block int index = 0;
        return ^id(id acc, id val) {
            return indexedMapFunc(index++, val) == nil ? acc : reducer(acc, val);
        };
    };
}

TKTransducer TKUnique(void) {
    return ^TKReducer(TKReducer reducer) {
        NSMutableSet *inTheFinal = [NSMutableSet new];

        return ^id(id acc, id val) {
            if ([inTheFinal containsObject:val]) {
                return acc;
            }

            [inTheFinal addObject:val];
            return reducer(acc, val);
        };
    };
}

TKTransducer TKWindowed(int length)
{
    return ^TKReducer(TKReducer reducer) {
        __block BOOL firstValue = YES;
        NSMutableArray *windowedValues = [NSMutableArray arrayWithCapacity:length];

        return ^id(id acc, id val) {
            if (firstValue) {
                for (int i = 0; i < length; ++i) {
                    [windowedValues addObject:val];
                }
                firstValue = NO;
            } else {
                [windowedValues removeObjectAtIndex:0];
                [windowedValues addObject:val];
            }

            return reducer(acc, [windowedValues copy]);
        };
    };
}


#pragma mark - Transducer Composition
TKTransducer TKComposeTransducers(TKTransducer f, TKTransducer g)
{
    return ^TKReducer(TKReducer reducer) {
        return g(f(reducer));
    };
}

TKTransducer TKComposeTransducersArray(NSArray *transducers) {
    return [transducers.reverseObjectEnumerator tk_reduce:^id(TKTransducer acc, TKTransducer val) {
        return TKComposeTransducers(acc, val);
    } initial:TKIdentity()];
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
