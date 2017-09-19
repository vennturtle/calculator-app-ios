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
    
    // command stack
    private var stack: [Command] = []
    
    // describes a single command on the stack
    private struct Command : CustomStringConvertible {
        public var previousValue: Double
        public var button: String
        public var operation: Operation
        public var operand: Double?
        
        public var description: String {
            let str = "pv: \(previousValue), btn: \(button), "
            return "cmd(" + str + "operand: " + (operand != nil ? "\(operand!)" : "nil") + ")"
        }
        
        public var isPending: Bool {
            switch(operation){
            case .binary:
                return operand == nil
            default:
                return false
            }
        }
        
        public func execute(on: Double) -> Double {
            switch(operation){
            case .binary(let function):
                if operand != nil {
                    return function(on, operand!)
                }
                else {
                    return on
                }
            case .unary(let function):
                return function(on)
            case .constant(let value):
                return value
            default:
                return on
            }
        }
        
        public func modifyHistory(history: String) -> String {
            switch(operation){
            case .binary:
                return "\(history) \(button) " + (operand != nil ? "\(operand!)" : "")
            case .unary:
                if button == "x²" {
                    return "(\(history))²"
                }
                else {
                    return "\(button)(\(history))"
                }
            default:
                return history
            }
        }
    }
    
    // history
    // TODO: currentHistoryIndex that stores how far back history should how
    // perhaps this should be set whenever equals is pressed
    public var hist: String {
        if stack.isEmpty {
            return "0"
        }
        else {
            var currentHistory = String(stack.first!.previousValue)
            for cmd in stack {
                currentHistory = cmd.modifyHistory(history: currentHistory)
            }
            return currentHistory
        }
    }
    
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
        stack = []
    }
    
    // executes an operation based on the given button and display input,
    // returns the newest display value to be output
    public mutating func exec(button: String, input:Double) -> Double {
        if let operation = operations[button] {
            switch(operation){
            case .binary:
                // handle the previous binary expression if it exists, and enqueue the current one
                if !stack.isEmpty && stack.last!.isPending {
                    // pop the pending binary operation and fill in the operand
                    var cmd = stack.popLast()!
                    cmd.operand = input
                    
                    // push the command back onto the stack
                    stack.append(cmd)
                    acc = stack.last!.execute(on: acc)
                    
                    //acc = pendingOperation!(acc, input)
                    //pendingOperation = function
                }
                else {
                    acc = input
                    stack.append(Command(previousValue: acc, button: button, operation: operation, operand: nil))
                }
            case .unary:
                // handle pending operation if one exists
                if !stack.isEmpty && stack.last!.isPending {
                    // pop the pending binary operation and fill in the operand
                    var cmd = stack.popLast()!
                    cmd.operand = input
                    
                    // push the command back onto the stack
                    stack.append(cmd)
                    acc = stack.last!.execute(on: acc)

                    //acc = pendingOperation!(acc, input);
                    //pendingOperation = nil
                }
                else {
                    acc = input
                }
                
                stack.append(Command(previousValue: acc, button: button, operation: operation, operand: nil))
                
                // handle the current unary operation
                acc = stack.last!.execute(on: acc)
            case .constant(let value):
                return value
            case .equals:
                // handle the last pending binary operation if it exists,
                // or repeat the last executed binary operation if one exists
                if stack.isEmpty {
                    acc = input
                }
                else if stack.last!.isPending {
                    // pop the pending binary operation and fill in the operand
                    var cmd = stack.popLast()!
                    cmd.operand = input
                    
                    // push the command back onto the stack
                    stack.append(cmd)
                    
                    acc = stack.last!.execute(on: acc)
                    
                    //acc = pendingOperation!(acc, input)
                    //lastOperation = (pendingOperation!, input)
                }
                else {
                    stack.append(stack.last!)
                    acc = stack.last!.execute(on: acc)
                }
                pendingOperation = nil
            }
            print("\(stack)")
            return acc
        }
        else { return input }
    }
    
    public var history: String {
        return hist
    }
    
    public mutating func setOperand(variableName: String){
        variableValues[variableName] = 0.0
    }
    var variableValues: [String:Double] = [:]
}
