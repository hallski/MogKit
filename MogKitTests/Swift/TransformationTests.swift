//
//  Transformation.swift
//  MogKit
//
//  Created by Mikael Hallendal on 27/04/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

// https://gist.github.com/robrix/d88a99214b3208e8548a

import Foundation
import MogKit
import XCTest

class TransformationTests : XCTestCase {
    
    func testMap() {
        let array = [1, 2, 3, 4]
        let expected = [11, 12, 13, 14]

        let map = Map({ $0 + 10 }).transduce { $0 + [$1] }
        
        let result = reduce(array, [], map)

        XCTAssertEqual(result, expected)
    }

    func testFilter() {
        let array = [1, 10, 15, 20]
        let expected = [10, 15]
        
        let filter = Filter({ $0 >= 10 && $0 <= 15}).transduce { $0 + [$1] }
        let result = reduce(array, [], filter)
        
        XCTAssertEqual(result, expected)
    }

    func testComposition() {
        let array = [1, 10, 100]
        let expected = ["10", "100"]
        
        let m = Map{ (val: Int) in return String(val) }
        let f = Filter { (val: String) in return count(val) >= 2 }
        
        let xform = m >>> f
        let result = reduce(array, [], xform.transduce({ $0 + [$1] }))
        
        XCTAssertEqual(result, expected)
    }
}





