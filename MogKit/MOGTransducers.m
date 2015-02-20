//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MogTransducers.h"
#import "MOGOperations.h"
#import "NSEnumerator+MogKit.h"


MOGTransducer MOGIdentity(void) {
    return ^MOGReducer(MOGReducer reducer) {
        return reducer;
    };
}

MOGTransducer MOGMap(id (^mapFunc)(id))
{
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

MOGTransducer MOGFilter(MOGPredicate predicate)
{
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return predicate(val) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGRemove(MOGPredicate predicate) {
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return predicate(val) ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGTake(int n)
{
    return ^MOGReducer(MOGReducer reducer) {
        __block int left = n;
        return ^id(id acc, id val) {
            return left-- > 0 ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGTakeWhile(MOGPredicate predicate)
{
    return ^MOGReducer(MOGReducer reducer) {
        __block BOOL keepTaking = YES;
        return ^id(id acc, id val) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            return keepTaking ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGTakeNth(int n) {
    return ^MOGReducer(MOGReducer reducer) {
        __block int i = 0;
        return ^id(id acc, id val) {
            return (i++ % n == 0) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGDrop(int n) {
    return ^MOGReducer(MOGReducer reducer) {
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

MOGTransducer MOGDropWhile(MOGPredicate predicate) {
    return ^MOGReducer(MOGReducer reducer) {
        __block BOOL keepDropping = YES;
        return ^id(id acc, id val) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGReplace(NSDictionary *replacements) {
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            val = replacements[val] ?: val;

            return reducer(acc, val);
        };
    };
}

MOGTransducer MOGKeep(MOGMapFunc func) {
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return func(val) == nil ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGKeepIndexed(MOGIndexedMapFunc indexedMapFunc) {
    return ^MOGReducer(MOGReducer reducer) {
        __block int index = 0;
        return ^id(id acc, id val) {
            return indexedMapFunc(index++, val) == nil ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGUnique(void) {
    return ^MOGReducer(MOGReducer reducer) {
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

MOGTransducer MOGWindowed(int length)
{
    return ^MOGReducer(MOGReducer reducer) {
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
MOGTransducer MOGComposeTransducers(MOGTransducer f, MOGTransducer g)
{
    return ^MOGReducer(MOGReducer reducer) {
        return g(f(reducer));
    };
}

MOGTransducer MOGComposeTransducersArray(NSArray *transducers) {
    return MOGEnumerableReduce(transducers.reverseObjectEnumerator, ^id(MOGTransducer acc, MOGTransducer val) {
        return MOGComposeTransducers(acc, val);
    }, MOGIdentity());
}
