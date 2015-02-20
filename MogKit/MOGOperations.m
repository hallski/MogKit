//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MOGOperations.h"


id MOGEnumerableReduce(id<MOGEnumerable> source, MOGReducer reducer, id initial)
{
    id obj;
    id acc = initial;

    while ((obj = [source mog_nextValue])) {
        acc = reducer(acc, obj);
    }

    return acc;
}

id MOGEnumerableTransduce(id<MOGEnumerable> source, MOGReducer reducer, id initial, MOGTransducer transducer)
{
    return MOGEnumerableReduce(source, transducer(reducer), initial);
}
