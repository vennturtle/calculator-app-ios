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
    
    // whether or not user has started entering a new value
    var userIsTyping = false
    
    private var brain: CalculatorBrain = CalculatorBrain()
    private var memory = 0.0
    private var display: CalculatorDisplay = CalculatorDisplay()
    
    // handles input whenever user taps on a digit button
    @IBAction func enterDig(_ sender: UIButton) {
        if !userIsTyping {
            display.clear()
            userIsTyping = true
        }
        display.append(digit: sender.currentTitle!)
        output.text = display.value
    }
    
    // handles input whenever user taps on negative sign
    @IBAction func negate(_ sender: UIButton) {
        if !userIsTyping {
            display.clear()
            userIsTyping = true
        }
        display.negate()
        output.text = display.value
    }
    
    // handles input whenever user taps on decimal point
    @IBAction func decimate(_ sender: UIButton) {
        if !userIsTyping {
            display.clear()
            userIsTyping = true
        }
        display.decimal()
        output.text = display.value
    }
    
    // if user presses clear once, it clears the current display
    // if user presses clear once more, it resets the state of the calculator brain
    @IBAction func clear(_ sender: UIButton) {
        if display.value == "0" || !userIsTyping {
            brain.reset()
        }
        display.clear()
        
        output.text = display.value
        history.text = brain.history
        userIsTyping = false
    }
    
    // performs a calculation whenever an operator is pressed,
    // updates the display with the results of the calculation
    @IBAction func operate(_ sender: UIButton) {
        userIsTyping = false
        let newValue = brain.exec(button: sender.currentTitle!, input: Double(display.value)!)
        display.value = String(newValue)
        output.text = display.value
        history.text = brain.history
    }
    
    // performs an operation involving the calculator memory
    @IBAction func memoryOperate(_ sender: UIButton) {
        let function = sender.currentTitle!
        switch(function){
        case "MC":
            memory = 0.0
        case "MR":
            display.value = String(memory)
            output.text = display.value
            userIsTyping = false
        case "MS":
            memory = Double(display.value)!
        case "M+":
            memory += Double(display.value)!
            display.value = String(memory)
            output.text = display.value
            userIsTyping = false
        default:
            output.text = display.value
        }
    }
}

