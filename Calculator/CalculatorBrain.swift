//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Brandon Cecilio on 9/6/17.
//  Copyright © 2017 Brandon Cecilio. All rights reserved.
//

import Foundation

// Stores the value currently being entered by the user, as a string
struct CalculatorDisplay {
    private var rawValue = "0"
    
    // computed property detecting if the current input is at its default state
    public var hasValue: Bool {
        get {
            return rawValue != "0"
        }
    }
    
    // resets the current input
    public mutating func clear(){
        rawValue = "0"
    }
    
    // adds a digit to the end of the current input
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
    
    // adds or removes a negative sign to the end of the current input
    public mutating func negate(){
        if let index = rawValue.range(of: "-") { // detect if negative sign is currently present
            rawValue.remove(at: index.lowerBound)
        }
        else {
            rawValue.insert("-", at: rawValue.startIndex)
        }
    }
    
    // adds a decimal point to the end of the current input, if one does not already exist
    public mutating func decimal(){
        if rawValue.range(of: ".") == nil { // detect if decimal point is currently present
            rawValue += "."
        }
    }
    
    // computed property for accessing the current value of the input
    public var value: String {
        get {
            return rawValue
        }
        set(newValue) {
            rawValue = newValue
        }
    }
}

// Describes the logic behind an operating calculator
struct CalculatorBrain {
    // current working value
    private var acc: Double = 0
    
    // next operation that is waiting on an input from the user to be completed
    private var pendingOperation: ((Double, Double) -> Double)?
    
    // last completed operation, allows user to repeat operation upon pressing "equals" button
    private var lastOperation: (((Double, Double) -> Double), Double)?
    
    // current operation history
    private var operationHistory = "0"
    
    // last-pressed button
    private var lastButton: String?
    
    // describes types of operations calculator can do, mostly defined as closures
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
    }
    
    // dictionary associating button labels to operations, mostly defined as closures
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
    
    // resets the state of the calculator
    public mutating func reset(){
        // should reset function stack
        acc = 0
        pendingOperation = nil
        lastOperation = nil
        operationHistory = "0"
        lastButton = nil
    }
    
    // executes an operation based on the given button and display input,
    // returns the newest display value to be output
    public mutating func exec(button: String, input:Double) -> Double {
        if let operation = operations[button] {
            switch(operation){
            case .binary(let function):
                // update the current operation history
                if operationHistory == "0" || pendingOperation == nil {
                    operationHistory = "\(input) \(button) "
                }
                else {
                    operationHistory += "\(input) \(button) "
                }
                lastButton = button
                
                // handle the previous binary expression if it exists, and enqueue the current one
                if pendingOperation == nil {
                    acc = input
                    pendingOperation = function
                }
                else {
                    acc = pendingOperation!(acc, input)
                    pendingOperation = function
                }
            case .unary(let function):
                // handle pending operation if one exists
                if pendingOperation != nil {
                    operationHistory = "\(acc) \(lastButton!) \(input)"
                    acc = pendingOperation!(acc, input);
                    pendingOperation = nil
                }
                else {
                    operationHistory = String(input)
                }
                
                // update the current operation history
                if button == "x²" {
                    operationHistory = "(\(operationHistory))²"
                }
                else {
                    operationHistory = "\(button)(\(operationHistory))"
                }
                
                // handle the current unary operation
                acc = function(input)
                lastButton = button
            case .constant(let value):
                return value
            case .equals:
                // handle the last pending binary operation if it exists,
                // or repeat the last executed binary operation if one exists
                if pendingOperation == nil && lastOperation == nil {
                    acc = input
                    operationHistory = String(input)
                }
                else if pendingOperation != nil {
                    acc = pendingOperation!(acc, input)
                    lastOperation = (pendingOperation!, input)
                    operationHistory += String(input)
                }
                else if lastOperation != nil {
                    let (function, lastInput) = lastOperation!
                    acc = function(acc, lastInput)
                    operationHistory += " \(lastButton!) \(lastInput)"
                }
                pendingOperation = nil
            }
            return acc
        }
        else { return input }
    }
    
    // computed property for the latest value of the current operation history
    public var history: String {
        if operationHistory.characters.count < 34 {
            return operationHistory
        }
        else {
            let index = operationHistory.index(operationHistory.endIndex, offsetBy: -34)
            return operationHistory.substring(from: index)
        }
        
    }
}
