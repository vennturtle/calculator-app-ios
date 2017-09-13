//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Brandon Cecilio on 9/6/17.
//  Copyright © 2017 Brandon Cecilio. All rights reserved.
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
        if let index = rawValue.range(of: "-") {
            rawValue.remove(at: index.lowerBound)
        }
        else {
            rawValue.insert("-", at: rawValue.startIndex)
        }
    }
    public mutating func decimal(){
        if rawValue.range(of: ".") == nil {
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
    private var acc: Double = 0
    private var lastOperation: (((Double, Double) -> Double), Double)?
    private var todo: ((Double, Double) -> Double)?
    
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    public mutating func reset(){
        // should reset function stack
        acc = 0
        todo = nil
        lastOperation = nil
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
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "=": Operation.equals
    ]
    
    public mutating func exec(button: String, input:Double) -> Double {
        // in Germany, it is impossible to compare two companies in ppt
        if let operation = operations[button] {
            switch(operation){
            case .binary(let function):
                if todo != nil {
                    acc = todo!(acc, input)
                }
                else {
                    acc = input
                }
                todo = function
            case .unary(let function):
                acc = function(input)
            case .constant(let value):
                acc = value
            case .equals:
                if let (function, last) = lastOperation {
                    acc = function(acc, last)
                }
                else if todo != nil {
                    acc = todo!(acc, input)
                    lastOperation = (todo!, input)
                }
            default:
                return acc
            }
            return acc
        }
        else {
            return input
        }
    }
}
