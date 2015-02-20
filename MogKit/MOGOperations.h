//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogTypes.h"


id MOGEnumerableReduce(id<MOGEnumerable> source, MOGReducer reducer, id initial);
id MOGEnumerableTransduce(id<MOGEnumerable> source, MOGReducer reducer, id initial, MOGTransducer transducer);
