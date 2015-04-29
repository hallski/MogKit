//
//  Transformation.swift
//  MogKit
//
//  Created by Mikael Hallendal on 27/04/15.
//  Copyright (c) 2015 Mikael Hallendal. All rights reserved.
//

import Foundation


public protocol Transformation {
    typealias Element
    typealias BaseElement
    
    func transduce<AccumType>(reducer: (AccumType, Element) -> AccumType) -> (AccumType, BaseElement) -> AccumType;
}


public struct Map<T, U>: Transformation {
    public init(_ map: T -> U) {
        self.map = map
    }
    
    public func transduce<AccumType>(reducer: (AccumType, U) -> AccumType) -> (AccumType, T) -> AccumType {
        return {
            reducer($0, self.map($1))
        }
    }

    private let map: T -> U
    
}

public struct Filter<T>: Transformation {
    public init(_ predicate: T -> Bool) {
        self.predicate = predicate
    }
    
    public func transduce<AccumType>(reducer: (AccumType, T) -> AccumType) -> (AccumType, T) -> AccumType {
        return {
            self.predicate($1) ? reducer($0, $1) : $0
        }
    }
    
    private let predicate: T -> Bool
}

public struct Remove<T>: Transformation {
    public init(_ predicate: T -> Bool) {
        self.predicate = predicate
    }
    
    public func transduce<AccumType>(reducer: (AccumType, T) -> AccumType) -> (AccumType, T) -> AccumType {
        return {
            self.predicate($1) ? $0 : reducer($0, $1)
        }
    }
    
    private let predicate: T -> Bool
}

public struct Take<T>: Transformation {
    public init(_ take: Int) {
        self.take = take
    }
    
    public func transduce<AccumType>(reducer: (AccumType, T) -> AccumType) -> (AccumType, T) -> AccumType {
        var taken = 0
        return {
            return taken++ < self.take ? reducer($0, $1) : $0
        }
    }
    
    private let take: Int
}


// Should probably have a different name (UnwrapOptional) or something
public struct DropNil<T>: Transformation {
    public init() {}
    
    public func transduce<AccumType>(reducer: (AccumType, T) -> AccumType) -> (AccumType, Optional<T>) -> AccumType {
        return {
            if let val = $1 {
                return reducer($0, val)
            } else {
                return $0
            }
        }
    }
}

public struct Compose<F: Transformation, G: Transformation where F.Element == G.BaseElement>: Transformation {
    typealias Element = G.Element
    typealias BaseElement = F.BaseElement
    
    public init(_ f: F, _ g: G) {
        self.f = f
        self.g = g
    }
    
    public func transduce<AccumType>(reducer: (AccumType, G.Element) -> AccumType) -> ((AccumType, F.BaseElement) -> AccumType) {
        return self.f.transduce(self.g.transduce(reducer))
    }
    
    private let f: F
    private let g: G
}


infix operator |> { associativity right }
public func |> <F: Transformation, G: Transformation where F.Element == G.BaseElement> (f: F, g: G) -> Compose<F,G> {
    return Compose(f, g)
}

