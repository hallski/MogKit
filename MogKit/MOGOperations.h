//
// MogKit
//
// Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MogTypes.h"


id MOGEnumerableReduce(MOGReducer reducer, id initial, id<MOGEnumerable> source);
id MOGEnumerableTransduce(MOGTransducer transducer, MOGReducer reducer, id initial, id<MOGEnumerable> source);
