//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef id (^MOGReducer) (id acc, id val);

MOGReducer MOGArrayAppendReducer(void);
MOGReducer MOGMutableArrayAppendReducer(void);

MOGReducer MOGLastValueReducer(void);

id MOGReduce(id<NSFastEnumeration> source, MOGReducer reducer, id initial);
