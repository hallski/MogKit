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
    
    func testMapEmptyArray() {
        let array = []
        let expected = []
        
        let result = reduce(array, [], Map({ $0 }).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }
    
    func testTransformWithEmptyValue() {
        let array = [1, 2, 3]
        let expected = [111, 222, 333, 11, 12, 13]
        
        let result = reduce(array, [111, 222, 333], Map({ $0 + 10 }).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

    func testFilter() {
        let array = [1, 10, 15, 20]
        let expected = [10, 15]
        
        let filter = Filter({ $0 >= 10 && $0 <= 15}).transduce { $0 + [$1] }
        let result = reduce(array, [], filter)
        
        XCTAssertEqual(result, expected)
    }
    
    func testRemove() {
        let array = [1, 10, 15, 20]
        let expected = [1, 20]
        
        let result = reduce(array, [], Remove({ $0 >= 10 && $0 <= 15}).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }
    
    func testTake() {
        let array = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
        let expected = [1, 2, 3, 4, 5]
        
        let result = reduce(array, [], Take(5).transduce { $0 + [$1] })
        XCTAssertEqual(result, expected)
    }
    
    func testTakeWithZero() {
        let array = [1, 2]
        let expected = []
        
        let result = reduce(array, [], Take(0).transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

    func testDropNil() {
        let array = [1, 2, 3, 4, 5]
        let expected = [1, 3, 5]
        
        let map = Map { (val: Int) -> Optional<Int> in
            return val % 2 == 0 ? nil : val
        }
        let xform = map |> DropNil()
        
        let result = reduce(array, [], xform.transduce { $0 + [$1] })
        
        XCTAssertEqual(result, expected)
    }

    func testComposition() {
        let array = [1, 10, 100]
        let expected = ["10", "100"]
        
        let m = Map{ (val: Int) in return String(val) }
        let f = Filter { (val: String) in return count(val) >= 2 }
        
        let xform = m |> f
        let result = reduce(array, [], xform.transduce({ $0 + [$1] }))
        
        XCTAssertEqual(result, expected)
    }
    
    func testCompositionMultiple() {
        let array = [50, 500, 5000, 50000]
        let expected = [50, 500]
        
        let xform = Map { (val: Int) in String(val) } |> Filter { (val: String) in count(val) < 4 } |> Map { (val: String) in val.toInt() } |> DropNil()
        
        let result = reduce(array, [], xform.transduce({ $0 + [$1] }))
        XCTAssertEqual(result, expected)
    }
}





