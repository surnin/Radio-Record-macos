//
//  ObserveEquals.swift
//  Record Player
//
//  Created by Евгений K on 07.05.2024.
//

import Combine

@propertyWrapper struct ObserveEquals<Value> {
    private var value: Value
    private weak var objectWillChange: ObservableObjectPublisher?
    
    var wrappedValue: Value {
        get { value }
        set {
            objectWillChange?.send()
        }
    }
    
    init(wrappedValue: Value) {
        self.value = wrappedValue
    }
    
    mutating func assignPublisher(_ publisher: ObservableObjectPublisher) {
        objectWillChange = publisher
    }
}
