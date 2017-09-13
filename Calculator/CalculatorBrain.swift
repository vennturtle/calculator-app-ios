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
    
    public var hasValue: Bool {
        get {
            return rawValue != "0"
        }
    }
    
    public mutating func clear(){
        rawValue = "0"
    }
    public mutating func append(digit: String){
        if rawValue == "-0" {
            rawValue = "-\(digit)"
        }
        else if hasValue {
            rawValue += digit
        }
        else if digit != "0" {
            rawValue = digit
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
        }
    }
    public var value: String {
        get {
            return rawValue
        }
        set(newValue) {
            rawValue = newValue
        }
    }
}

struct CalculatorBrain {
    private var acc: Double = 0
    private var pendingOperation: ((Double, Double) -> Double)?
    private var lastOperation: (((Double, Double) -> Double), Double)?
    private var history = "0"
    private var lastButton: String?
    
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    public mutating func reset(){
        // should reset function stack
        acc = 0
        pendingOperation = nil
        lastOperation = nil
        history = "0"
        lastButton = nil
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
                if history == "0" || pendingOperation == nil {
                    history = "\(input) \(button) "
                }
                else {
                    history += "\(input) \(button) "
                }
                lastButton = button
                
                if pendingOperation == nil {
                    acc = input
                    pendingOperation = function
                }
                else {
                    acc = pendingOperation!(acc, input)
                    pendingOperation = function
                }
            case .unary(let function):
                acc = function(input)
                if button == "x²" {
                    history = "(\(input))²"
                }
                else {
                    history = "\(button)(\(input))"
                }
                lastButton = nil
            case .constant(let value):
                acc = value
            case .equals:
                if pendingOperation == nil && lastOperation == nil {
                    acc = input
                    history = String(input)
                }
                else if pendingOperation != nil {
                    acc = pendingOperation!(acc, input)
                    lastOperation = (pendingOperation!, input)
                    history += String(input)
                }
                else if lastOperation != nil {
                    let (function, lastInput) = lastOperation!
                    acc = function(acc, lastInput)
                    history += " \(lastButton!) \(lastInput)"
                }
                pendingOperation = nil
            }
            return acc
        }
        else { return input }
    }
    
    public func getHistory() -> String {
        return history
    }
}
