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
    
    // command stack
    private var stack: [Command] = []
    
    // describes a single command on the stack
    private struct Command : CustomStringConvertible {
        public var previousValue: Double
        public var button: String
        public var operation: Operation
        public var operand: Double?
        
        public var description: String {
            let str = "\(previousValue) -> \(button)"
            return "(" + str + (operand != nil ? "\(operand!)" : "?") + ")"
        }
        
        public var isPending: Bool {
            switch(operation){
            case .binary:
                return operand == nil
            default:
                return false
            }
        }
        
        public var isUnary: Bool {
            switch(operation){
            case .unary:
                return true
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
            case .equals:
                return history + " ="
            default:
                return history
            }
        }
    }
    
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
        acc = 0
        stack = []
    }
    
    // executes an operation based on a given button and display input and returns the resulting acc
    public mutating func exec(button: String, input:Double) -> Double {
        if let operation = operations[button] {
            switch(operation){
            case .binary:
                // handle previous command if one exists
                if stack.isEmpty { // initialize acc to current input
                    acc = input
                }
                else if stack.last!.isPending { // handle pending binary operation
                    
                    // pop the pending binary operation and fill in the operand
                    var oldCmd = stack.popLast()!
                    oldCmd.operand = input
                    
                    // push the command back onto the stack and execute
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc)
                }
                else if stack.last!.button == "=" { // if last command was equals, clear the stack
                    let equalsCmd = stack.popLast()!
                    if equalsCmd.previousValue != input { // this implies user set new input
                        acc = input
                    }
                    stack = []
                }
                else if stack.last!.isUnary && acc != input { // if last command was unary and the display was changed, clear the stack
                    acc = input
                    stack = []
                }
                
                // enqueue new pending binary operation
                let newCmd = Command(previousValue: acc, button: button, operation: operation, operand: nil)
                stack.append(newCmd)
                
            case .unary:
                if stack.isEmpty {
                    acc = input
                }
                else if stack.last!.isPending { // handle pending binary operation
                    var oldCmd = stack.popLast()!
                    oldCmd.operand = input
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc)
                }
                else if stack.last!.button == "=" { // if last command was equals, clear the stack
                    let lastCmd = stack.popLast()!
                    if lastCmd.previousValue != input { // this implies user set new input
                        acc = input
                    }
                    stack = []
                }
                else if stack.last!.isUnary && acc != input { // if last command was unary and the display was changed, clear the stack
                    acc = input
                    stack = []
                }
                
                // enqueue and execute new expression
                let newCmd = Command(previousValue: acc, button: button, operation: operation, operand: nil)
                stack.append(newCmd)
                acc = stack.last!.execute(on: acc)
                
            case .constant(let value):
                return value
                
            case .equals:
                if stack.isEmpty { // set acc to input
                    acc = input
                    
                    // push new equals command onto the stack
                    let equalsCmd = Command(previousValue: acc, button: button, operation: operation, operand: nil)
                    stack.append(equalsCmd)
                }
                else if stack.last!.isPending { // handle pending binary operation
                    var oldCmd = stack.popLast()!
                    oldCmd.operand = input
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc)
                    
                    // push new equals command onto the stack
                    let equalsCmd = Command(previousValue: acc, button: button, operation: operation, operand: nil)
                    stack.append(equalsCmd)
                }
                else if stack.last!.button == "=" { // redo last binary command before last equals
                    
                    // pop last equals command
                    var equalsCmd = stack.popLast()!
                    
                    // copy last command if it exists and update the previous value
                    if let last = stack.last {
                        var lastCmd = last
                        lastCmd.previousValue = acc
                        
                        // push copied command onto the stack and execute
                        stack.append(lastCmd)
                        acc = stack.last!.execute(on: acc)
                    }
                    else {
                        acc = input
                    }
                    
                    // update equals command with new acc and push back onto stack
                    equalsCmd.previousValue = acc
                    stack.append(equalsCmd)
                }
                else { // redo last unary command
                    if let last = stack.last {
                        var lastCmd = last
                        lastCmd.previousValue = acc
                        
                        stack.append(lastCmd)
                        acc = stack.last!.execute(on: acc)
                    }
                }
            }
            print("\(stack)") // debug
            return acc
        }
        else { return input }
    }
    
    // computer property showing command history
    public var history: String {
        if stack.isEmpty {
            return "0"
        }
        else {
            var hist = String(stack.first!.previousValue)
            for cmd in stack {
                hist = cmd.modifyHistory(history: hist)
            }
            return hist
        }
    }

    
    public mutating func setOperand(variableName: String){
        variableValues[variableName] = 0.0
    }
    var variableValues: [String:Double] = [:]
}
