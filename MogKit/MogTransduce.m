//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MogTransduce.h"


MOGTransducer MOGIdentityTransducer(void) {
    return ^MOGReducer(MOGReducer reducer) {
        return reducer;
    };
}

MOGTransducer MOGMapTransducer(id (^mapFunc)(id))
{
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

MOGTransducer MOGFilterTransducer(MOGPredicate predicate)
{
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return predicate(val) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGRemoveTransducer(MOGPredicate predicate) {
    return MOGFilterTransducer(^BOOL(id val) {
        return !predicate(val);
    });
}

MOGTransducer MOGTakeTransducer(int n)
{
    return ^MOGReducer(MOGReducer reducer) {
        __block int left = n;
        return ^id(id acc, id val) {
            return left-- > 0 ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGTakeWhileTransducer(MOGPredicate predicate)
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

MOGTransducer MOGTakeNthTransducer(int n) {
    return ^MOGReducer(MOGReducer reducer) {
        __block int i = 0;
        return ^id(id acc, id val) {
            return (i++ % n == 0) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransducer MOGDropTransducer(int n) {
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

MOGTransducer MOGDropWhileTransducer(MOGPredicate predicate) {
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

MOGTransducer MOGReplaceTransducer(NSDictionary *replacements) {
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            val = replacements[val] ?: val;

            return reducer(acc, val);
        };
    };
}

MOGTransducer MOGKeepTransducer(MOGMapFunc func) {
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            return func(val) == nil ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGKeepIndexedTransducer(MOGIndexedMapFunc func) {
    return ^MOGReducer(MOGReducer reducer) {
        __block int index = 0;
        return ^id(id acc, id val) {
            return func(index++, val) == nil ? acc : reducer(acc, val);
        };
    };
}

MOGTransducer MOGUniqueTransducer(void) {
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

MOGTransducer MOGCatTransducer(void)
{
    return ^MOGReducer(MOGReducer reducer) {
        return ^id(id acc, id val) {
            if (![val conformsToProtocol:@protocol(NSFastEnumeration)]) {
                // Leave untouched if it's not a fast enumeration
                return reducer(acc, val);
            }

            for (id v in val) {
                acc = reducer(acc, v);
            }

            return acc;
        };
    };
}

MOGTransducer MOGMapCatTransducer(MOGMapFunc mapFunc)
{
    return MOGCompose(MOGMapTransducer(mapFunc), MOGCatTransducer());
}

MOGTransducer MOGWindowTransducer(int length)
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
MOGTransducer MOGCompose(MOGTransducer f, MOGTransducer g)
{
    return ^MOGReducer(MOGReducer reducer) {
        return f(g(reducer));
    };
}

MOGTransducer MOGComposeArray(NSArray *transducers) {
    return MOGReduce(transducers, ^id(MOGTransducer acc, MOGTransducer val) {
        return MOGCompose(acc, val);
    }, MOGIdentityTransducer());
}

id MOGTransduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransducer transducer)
{
    return MOGReduce(source, transducer(reducer), initial);
}
