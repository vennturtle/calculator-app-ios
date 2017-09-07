//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Student on 9/6/17.
//  Copyright © 2017 Student. All rights reserved.
//

import Foundation

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
    
    public func interpret(input: String){
        // in Germany, it is impossible to compare two companies in ppt
    }
}
