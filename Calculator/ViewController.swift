//
//  ViewController.swift
//  Calculator
//
//  Created by Brandon Cecilio 9/5/17.
//  Copyright © 2017 Brandon Cecilio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    // displays the current operation history
    @IBOutlet weak var history: UILabel!
    
    // displays the current display value
    @IBOutlet weak var output: UILabel!
    
    // holds the current variable label
    @IBOutlet weak var variable: UITextField!
    
    // whether or not user has started entering a new value
    var userIsTyping = false
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var memory = 0.0
    private var input: CalculatorInput = CalculatorInput()
    
    // handles input whenever user taps on a digit button
    @IBAction func enterDig(_ sender: UIButton) {
        if !userIsTyping {
            input.clear()
            userIsTyping = true
        }
        input.append(digit: sender.currentTitle!)
        output.text = input.value
    }
    
    // handles input whenever user taps on negative sign
    @IBAction func negate(_ sender: UIButton) {
        if !userIsTyping {
            input.clear()
            userIsTyping = true
        }
        input.negate()
        output.text = input.value
    }
    
    // handles input whenever user taps on decimal point
    @IBAction func decimate(_ sender: UIButton) {
        if !userIsTyping {
            input.clear()
            userIsTyping = true
        }
        input.decimal()
        output.text = input.value
    }
    
    // if user presses clear once, it clears the current display
    // if user presses clear once more, it resets the state of the calculator brain
    @IBAction func clear(_ sender: UIButton) {
        if input.value == "0" || !userIsTyping {
            brain.reset()
        }
        input.clear()
        
        output.text = input.value
        history.text = brain.history
        userIsTyping = false
    }
    
    // performs a calculation whenever an operator is pressed,
    // updates the display with the results of the calculation
    @IBAction func operate(_ sender: UIButton) {
        userIsTyping = false
        let newValue = brain.execute(button: sender.currentTitle!, input: Double(input.value)!)
        input = CalculatorInput(newValue)
        output.text = input.value
        history.text = brain.history
    }
    
    // performs an operation involving the calculator memory
    @IBAction func memoryOperate(_ sender: UIButton) {
        let function = sender.currentTitle!
        switch(function){
        case "MC":
            memory = 0.0
        case "MR":
            input = CalculatorInput(memory)
            output.text = input.value
            userIsTyping = false
        case "MS":
            memory = Double(input.value)!
        case "M+":
            memory += Double(input.value)!
            input = CalculatorInput(memory)
            output.text = input.value
            userIsTyping = false
        default:
            output.text = input.value
        }
    }
    
    // if user is still typing, this deletes the character
    @IBAction func undo(){
        if userIsTyping && input.hasValue {
            input.delete()
            output.text = input.value
        }
        else {
            let (oldValue, userIsNowTyping) = brain.undo()
            input = CalculatorInput(oldValue)
            userIsTyping = userIsNowTyping
            output.text = input.value
            history.text = brain.history
        }
    }
    
    // uses the currently selected variable as input
    @IBAction func variableRecall(_ sender: Any) {
        if let label = variable.text {
            input.setVar(label)
            output.text = input.value
        }
    }
    
    // sets the value of the currently selected variable
    @IBAction func variableSet(_ sender: Any) {
        if let label = variable.text {
            brain.variableValues[label] = Double(input.value)!
        }
    }
}

