//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import "MOGReducers.h"


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

