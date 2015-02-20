//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MOGOperations.h"


id MOGEnumerableReduce(MOGReducer reducer, id initial, id<MOGEnumerable> source)
{
    id obj;
    id acc = initial;

    while ((obj = [source mog_nextValue])) {
        acc = reducer(acc, obj);
    }

    return acc;
}

id MOGEnumerableTransduce(MOGTransducer transducer, MOGReducer reducer, id initial, id<MOGEnumerable> source)
{
    return MOGEnumerableReduce(transducer(reducer), initial, source);
}
