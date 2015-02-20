//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MogReduce.h"

MOGReducer MOGArrayAppendReducer(void) {
    return ^id(NSArray *acc, id val) {
        return [acc arrayByAddingObject:val];
    };
}

MOGReducer MOGMutableArrayAppendReducer(void) {
    return ^id(NSMutableArray *acc, id val) {
        [acc addObject:val];
        return acc;
    };
}

MOGReducer MOGLastValueReducer(void)
{
    return ^id(id _, id val) {
        return val;
    };
}

id MOGReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial)
{
    id acc = initial;
    for (id val in source) {
        acc = reducer(acc, val);
    }

    return acc;
}