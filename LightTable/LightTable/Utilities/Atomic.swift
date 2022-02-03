//
//  Atomic.swift
//  LightTable
//
//  Created by Fabio Riccardi on 2/3/22.
//

import Foundation

@propertyWrapper
class Atomic<Value> {
    private let queue = DispatchQueue(label: "com.glassimaging.atomic")
    private var value: Value

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var projectedValue: Atomic<Value> {
        return self
    }

    func mutate(_ mutation: (inout Value) -> Void) {
        return queue.sync {
            mutation(&value)
        }
    }

    var wrappedValue: Value {
        get {
            return queue.sync { value }
        }
        set {
            queue.sync { value = newValue }
        }
    }
}
