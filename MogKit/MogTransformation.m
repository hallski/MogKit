//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//


#import "MogTransformation.h"

MOGTransformation MOGIdentity(void) {
    return ^MOGReducer (MOGReducer reducer) {
        return ^(id acc, id val) {
            return reducer(acc, val);
        };
    };
}

MOGTransformation MOGMap(id (^mapFunc)(id))
{
    return ^MOGReducer (MOGReducer reducer) {
        return ^(id acc, id val) {
            return reducer(acc, mapFunc(val));
        };
    };
}

MOGTransformation MOGFilter(MOGPredicate predicate)
{
    return ^MOGReducer (MOGReducer reducer) {
        return ^(id acc, id val) {
            return predicate(val) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransformation MOGRemove(MOGPredicate predicate) {
    return MOGFilter(^BOOL(id val) {
        return !predicate(val);
    });
}

MOGTransformation MOGTake(NSUInteger n)
{
    return ^MOGReducer (MOGReducer reducer) {
        __block NSUInteger taken = 0;

        return ^(id acc, id val) {
            if (taken++ < n) {
                id newAcc = reducer(acc, val);
                return taken == n ? MOGEnsureReduced(newAcc) : newAcc;
            } else {
                return MOGEnsureReduced(acc);
            }
        };
    };
}

MOGTransformation MOGTakeWhile(MOGPredicate predicate)
{
    return ^MOGReducer (MOGReducer reducer) {
        __block BOOL keepTaking = YES;

        return ^(id acc, id val) {
            if (keepTaking) {
                keepTaking = predicate(val);
            }

            return keepTaking ? reducer(acc, val) : MOGEnsureReduced(acc);
        };
    };
}

MOGTransformation MOGTakeNth(NSUInteger n) {
    return ^MOGReducer (MOGReducer reducer) {
        __block NSUInteger i = 0;

        return ^(id acc, id val) {
            return (i++ % n == 0) ? reducer(acc, val) : acc;
        };
    };
}

MOGTransformation MOGDrop(NSUInteger n) {
    return ^MOGReducer (MOGReducer reducer) {
        __block NSUInteger dropped = 0;

        return ^(id acc, id val) {
            if (dropped < n) {
                dropped++;
                return acc;
            }

            return reducer(acc, val);
        };
    };
}

MOGTransformation MOGDropWhile(MOGPredicate predicate) {
    return ^MOGReducer (MOGReducer reducer) {
        __block BOOL keepDropping = YES;

        return ^(id acc, id val) {
            if (keepDropping) {
                keepDropping = predicate(val);
            }
            return keepDropping ? acc : reducer(acc, val);
        };
    };
}

MOGTransformation MOGDropNil(void) {
    return ^MOGReducer (MOGReducer reducer) {
        return ^id(id acc, id val) {
            return val != nil ? reducer(acc, val) : acc;
        };
    };
}

MOGTransformation MOGReplace(NSDictionary *replacements) {
    return MOGReplaceWithDefault(replacements, nil);
}

MOGTransformation MOGReplaceWithDefault(NSDictionary *replacements, id defaultValue)
{
    return MOGMap(^id(id val) {
        id replacement = replacements[val] ?: defaultValue;
        return replacement ?: val;
    });
}

MOGTransformation MOGMapDropNil(MOGMapBlock mapBlock) {
    return MOGCompose(MOGMap(mapBlock), MOGDropNil());
}

MOGTransformation MOGUnique(void) {
    return ^MOGReducer (MOGReducer reducer) {
        NSMutableSet *seenValues = [NSMutableSet new];

        return ^(id acc, id val) {
            if ([seenValues containsObject:val]) {
                return acc;
            }

            [seenValues addObject:val];
            return reducer(acc, val);
        };
    };
}

MOGTransformation MOGDedupe(void)
{
    return ^MOGReducer (MOGReducer reducer) {
        __block id previous = nil;

        return ^id(id acc, id val) {
            if ([val isEqual:previous]) {
                return acc;
            } else {
                previous = val;
                return reducer(acc, val);
            }
        };
    };
}

MOGTransformation MOGFlatten(void)
{
    return ^MOGReducer (MOGReducer reducer) {
        return ^(id acc, id val) {
            if (![val conformsToProtocol:@protocol(NSFastEnumeration)]) {
                // Leave untouched if it's not a fast enumeration
                return reducer(acc, val);
            }

            MOGReducer keepReduced = ^id(id a, id v) {
                a = reducer(a, v);
                return MOGIsReduced(a) ? MOGReduced(a) : a;
            };

            return MOGReduce(val, keepReduced, acc);
        };
    };
}

MOGTransformation MOGFlatMap(MOGMapBlock mapBlock)
{
    return MOGCompose(MOGMap(mapBlock), MOGFlatten());
}

MOGTransformation MOGWindow(NSUInteger length)
{
    return ^MOGReducer (MOGReducer reducer) {
        __block BOOL firstValue = YES;
        NSMutableArray *windowedValues = [NSMutableArray arrayWithCapacity:length];

        return ^(id acc, id val) {
            if (firstValue) {
                for (NSUInteger i = 0; i < length; ++i) {
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
MOGTransformation MOGCompose(MOGTransformation f, MOGTransformation g)
{
    return ^MOGReducer (MOGReducer reducer) {
        return f(g(reducer));
    };
}

MOGTransformation MOGComposeArray(NSArray *transducers)
{
    return MOGReduce(transducers, ^id(id f, id g) { return MOGCompose(f, g); }, MOGIdentity());
}

id MOGTransform(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransformation transformation)
{
    return MOGReduce(source, transformation(reducer), initial);
}
