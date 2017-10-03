//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Brandon Cecilio on 9/6/17.
//  Copyright © 2017 Brandon Cecilio. All rights reserved.
//

import Foundation

// Stores the value currently being entered by the user, as a string
struct CalculatorInput {
    private var rawValue = "0"
    var isVar = false
    
    init() {}
    init(_ value: Double){
        rawValue = String(value)
    }
    
    // computed property for accessing the current value of the input
    public var value: String {
        return rawValue
    }
    
    // computed property detecting if the current input is at its default state
    public var hasValue: Bool {
        get {
            return rawValue != "0"
        }
    }
    
    // resets the current input
    public mutating func clear(){
        rawValue = "0"
        isVar = false
    }
    
    // sets current input to variable label
    public mutating func setVar(_ varLabel: String){
        rawValue = varLabel
        isVar = true
    }
    
    // adds a digit to the end of the current input
    public mutating func append(digit: String){
        if isVar { clear() }
        
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
    
    public mutating func delete(){
        if isVar { clear() }
        else if rawValue == "-0" || rawValue.characters.count == 1 {
            rawValue = "0"
        }
        else if hasValue {
            rawValue.remove(at: rawValue.index(before: rawValue.endIndex))
            if rawValue == "-" {
                rawValue = "-0"
            }
        }
    }
    
    // adds or removes a negative sign to the end of the current input
    public mutating func negate(){
        if isVar { clear() }
        
        if let index = rawValue.range(of: "-") { // detect if negative sign is currently present
            rawValue.remove(at: index.lowerBound)
        }
        else {
            rawValue.insert("-", at: rawValue.startIndex)
        }
    }
    
    // adds a decimal point to the end of the current input, if one does not already exist
    public mutating func decimal(){
        if isVar { clear() }
        if rawValue.range(of: ".") == nil { // detect if decimal point is currently present
            rawValue += "."
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
        public var previousValue: AnyObject
        public var button: String
        public var operation: Operation
        public var operand: AnyObject?
        
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
        
        public var isBinary: Bool {
            switch(operation){
            case .binary:
                return true
            default:
                return false
            }
        }
        
        public var isEquals: Bool {
            switch(operation){
            case .equals:
                return true
            default:
                return false
            }
        }
        
        public func getPrev(_ variableValues: [String: Double]) -> Double{
            if previousValue is Double {
                return previousValue as! Double
            }
            else if previousValue is String {
                return variableValues[previousValue as! String] ?? 0.0
            }
            else {
                return 0.0
            }
        }
        
        public func execute(on: Double, variableValues: [String: Double]) -> Double {
            switch(operation){
            case .binary(let function):
                if operand == nil {
                    return on
                }
                else if operand is Double {
                    return function(on, operand! as! Double)
                }
                else if operand is String {
                    if let op = variableValues[operand! as! String] {
                        return function(on, op)
                    }
                    else { return 0.0 }
                }
                else { return 0.0 }
            case .unary(let function):
                return function(on)
            case .constant(let value):
                return value
            default:
                return on
            }
        }
        
        public func modifyHistory(history: String) -> String {
            var op = ""
            if operand is String {
                op = operand! as! String
            }
            else if operand is Double {
                op = String(operand! as! Double)
            }
            switch(operation){
            case .binary:
                return "\(history) \(button) " + op
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
    public mutating func execute(button: String, operand:Double, label: String?) -> Double {
        var input: Double
        if let variableName = label {
            if let val = variableValues[variableName] {
                input = val
            }
            else {
                setOperand(variableName: variableName)
                input = 0.0
            }
        }
        else {
            input = operand
        }
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
                    oldCmd.operand = (label != nil ? label as AnyObject : input as AnyObject)
                    
                    // push the command back onto the stack and execute
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc, variableValues: variableValues)
                }
                else if stack.last!.button == "=" { // if last command was equals, clear the stack
                    let equalsCmd = stack.popLast()!
                    if equalsCmd.getPrev(variableValues) != input { // this implies user set new input
                        acc = input
                    }
                    stack = []
                }
                else if stack.last!.isUnary && acc != input { // if last command was unary and the display was changed, clear the stack
                    acc = input
                    stack = []
                }
                
                // enqueue new pending binary operation
                var previousValue = acc as AnyObject
                if stack.isEmpty && label != nil {
                    previousValue = label as AnyObject
                }
                let newCmd = Command(previousValue: previousValue, button: button, operation: operation, operand: nil)
                stack.append(newCmd)
                
            case .unary:
                if stack.isEmpty {
                    acc = input
                }
                else if stack.last!.isPending { // handle pending binary operation
                    var oldCmd = stack.popLast()!
                    oldCmd.operand = (label != nil ? label as AnyObject : input as AnyObject)
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc, variableValues: variableValues)
                }
                else if stack.last!.button == "=" { // if last command was equals, clear the stack
                    let lastCmd = stack.popLast()!
                    if lastCmd.getPrev(variableValues) != input { // this implies user set new input
                        acc = input
                    }
                    stack = []
                }
                else if stack.last!.isUnary && acc != input { // if last command was unary and the display was changed, clear the stack
                    acc = input
                    stack = []
                }
                
                // enqueue and execute new expression
                var previousValue = acc as AnyObject
                if stack.isEmpty && label != nil {
                    previousValue = label as AnyObject
                }
                let newCmd = Command(previousValue: previousValue, button: button, operation: operation, operand: nil)
                stack.append(newCmd)
                acc = stack.last!.execute(on: acc, variableValues: variableValues)
                
            case .constant(let value):
                return value
                
            case .equals:
                if stack.isEmpty { // set acc to input
                    acc = input
                    
                    // push new equals command onto the stack
                    var previousValue = acc as AnyObject
                    if label != nil {
                        previousValue = label as AnyObject
                    }
                    let equalsCmd = Command(previousValue: previousValue, button: button, operation: operation, operand: nil)
                    stack.append(equalsCmd)
                }
                else if stack.last!.isPending { // handle pending binary operation
                    var oldCmd = stack.popLast()!
                    oldCmd.operand = (label != nil ? label as AnyObject : input as AnyObject)
                    stack.append(oldCmd)
                    acc = stack.last!.execute(on: acc, variableValues: variableValues)
                    
                    // push new equals command onto the stack
                    let equalsCmd = Command(previousValue: acc as AnyObject, button: button, operation: operation, operand: nil)
                    stack.append(equalsCmd)
                }
                else if stack.last!.button == "=" { // redo last binary command before last equals
                    
                    // pop last equals command
                    var equalsCmd = stack.popLast()!
                    
                    // copy last command if it exists and update the previous value
                    if let last = stack.last {
                        var lastCmd = last
                        lastCmd.previousValue = acc as AnyObject
                        
                        // push copied command onto the stack and execute
                        stack.append(lastCmd)
                        acc = stack.last!.execute(on: acc, variableValues: variableValues)
                    }
                    else {
                        acc = input
                    }
                    
                    // update equals command with new acc and push back onto stack
                    equalsCmd.previousValue = acc as AnyObject
                    stack.append(equalsCmd)
                }
                else { // redo last unary command
                    if let last = stack.last {
                        var lastCmd = last
                        lastCmd.previousValue = acc as AnyObject
                        
                        stack.append(lastCmd)
                        acc = stack.last!.execute(on: acc, variableValues: variableValues)
                    }
                }
            }
            print("\(stack)") // debug
            return acc
        }
        else { return input }
    }
    
    // undoes last operation and returns previous operand
    public mutating func undo() -> (displayValue: AnyObject, userIsTyping: Bool) {
        if let undoneCmd = stack.popLast() {
            if let last = stack.last {
                switch(last.operation){
                case .binary:
                    var lastCmd = stack.popLast()!
                    let lastOperand = lastCmd.operand!
                    lastCmd.operand = nil
                    acc = lastCmd.getPrev(variableValues)
                    stack.append(lastCmd)
                    
                    print("b undo -> \(stack)") // debug
                    return (displayValue: lastOperand, userIsTyping: true)
                
                case .unary:
                    acc = undoneCmd.getPrev(variableValues)
                    
                    print("u undo -> \(stack)") // debug
                    return (displayValue: acc as AnyObject, userIsTyping: false)
                default:
                    
                    print("d undo -> \(stack)") // debug
                    return (displayValue: acc as AnyObject, userIsTyping: false)
                }
            }
            else { // the stack is now empty
                print("e undo -> \(stack)") // debug
                return (displayValue: undoneCmd.previousValue, userIsTyping: true)
            }
        }
        return (displayValue: 0.0 as AnyObject, userIsTyping: false)
    }
    
    // computer property showing command history
    public var history: String {
        if stack.isEmpty {
            return "0"
        }
        else {
            var hist = ""
            //var hist = String(stack.first!.previousValue)
            let first = stack.first!.previousValue
            if first is String {
                hist = first as! String
                print("yeet (\(hist))")
            }
            else if first is Double {
                hist = String(first as! Double)
            }
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
