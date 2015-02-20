//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MOGOperations.h"

id MOGEnumerationReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial)
{
    id acc = initial;
    for (id val in source) {
        acc = reducer(acc, val);
    }

    return acc;
}

id MOGEnumerationTransduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial, MOGTransducer transducer)
{
    return MOGEnumerationReduce(source, transducer(reducer), initial);
}
