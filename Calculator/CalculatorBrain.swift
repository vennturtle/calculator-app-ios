//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Student on 9/6/17.
//  Copyright © 2017 Student. All rights reserved.
//

import Foundation

struct CalculatorDisplay {
    private var rawValue = "0"
    private var hasValue = false
    public mutating func clear(){
        rawValue = "0"
        hasValue = false
    }
    public mutating func append(digit: String){
        if hasValue {
            rawValue += digit
        }
        else if digit != "0" {
            rawValue = digit
            hasValue = true
        }
    }
    public mutating func negate(){
        if let numeric = Double(rawValue){
            rawValue = "\(-numeric)"
        }
    }
    public mutating func decimal(){
        if rawValue.index(of:".") == nil {
            rawValue += "."
            hasValue = true
        }
    }
    public var value: String {
        get {
            return rawValue
        }
        set(newValue) {
            rawValue = newValue
            hasValue = (newValue != "0")
        }
    }
}

struct CalculatorBrain {
    private var acc: Double
    private var memory: Double
    private var currentInput = "0"
    private var pending = false
    
    private enum Operation {
        case memory
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    public mutating func clear(){
        if currentInput != "0" {
            acc = 0
        }
        else {
            currentInput = "0"
        }
    }
    
    public mutating func appendChar(input: String){
        if currentInput == "0" {
            currentInput += input
        }
        else {
            currentInput = input
        }
    }
    public mutating func memClear(){
        memory = 0
    }
    
    public mutating func memRecall(){
        currentInput = "\(memory)"
    }
    
    public mutating func memStore(){
        memory = Double(currentInput)!
    }
    
    public mutating func memAdd(){
        memory += Double(currentInput)!
    }
    
    private var operations: [String:Operation] = [
        "+": Operation.binary({$0 + $1}),
        "-": Operation.binary({$0 - $1}),
        "×": Operation.binary({$0 * $1}),
        "÷": Operation.binary({$0 / $1}),
        "sin": Operation.unary({sin($0)}),
        "cos": Operation.unary({cos($0)}),
        "tan": Operation.unary({tan($0)}),
        "√": Operation.unary({sqrt($0)}),
        "x²": Operation.unary({$0 * $0}),
        "±": Operation.unary({-$0}),
        "π": Operation.constant(3.14159265),
        "e": Operation.constant(2.71828182),
        "=": Operation.equals
    ]
    
    public func interpret(button: String){
        // in Germany, it is impossible to compare two companies in ppt
        let function = operations[button] {
            switch(function){
                case .binary:
                    function(acc, input)
                case .unary:
                case .constant:
                case .equals:
                default:
            }
        }
        else {
            
        }
    }
}
