//
//  Optional+Extensions.swift
//  FoodServiceManager
//
//  Created by Victoria Kravets on 08.06.2018.
//  Copyright © 2018 Victoria Kravets. All rights reserved.
//

import Foundation

public extension Optional {
    public func apply<Result>(_ transform: ((Wrapped) -> Result)?) -> Result? {
        return self.flatMap { value in
            transform.map { $0(value) }
        }
    }
    
    public func apply<Value, Result>(_ value: Value?) -> Result?
        where Wrapped == (Value) -> Result
    {
        return self.flatMap { value.map($0) }
    }
    
    public func flatten<Result>() -> Result?
        where Wrapped == Result?
    {
        return self.flatMap { $0 }
    }
    
    public func `do`(_ action: (Wrapped) -> ()) {
        self.map(action)
    }
}
