//
//  ViewController.swift
//  Calculator
//
//  Created by Brandon Cecilio 9/5/17.
//  Copyright © 2017 Brandon Cecilio. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var history: UILabel!
    @IBOutlet weak var output: UILabel!
    var userIsTyping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private var brain: CalculatorBrain = CalculatorBrain()
    private var display: CalculatorDisplay = CalculatorDisplay()
    
    @IBAction func enterDig(_ sender: UIButton) {
        if !userIsTyping {
            display.clear()
            userIsTyping = true
        }
        display.append(digit: sender.currentTitle!)
        output.text = display.value
    }
    
    @IBAction func negate(_ sender: UIButton) {
        display.negate()
        output.text = display.value
    }
    
    @IBAction func decimate(_ sender: UIButton) {
        if !userIsTyping {
            display.clear()
            userIsTyping = true
        }
        display.decimal()
        output.text = display.value
    }
    
    @IBAction func clear(_ sender: UIButton) {
        display.clear()
        if display.value == "0" || !userIsTyping {
            brain.reset()
        }
        output.text = display.value
        userIsTyping = false
    }
    @IBAction func operate(_ sender: UIButton) {
        userIsTyping = false
        let newValue = brain.exec(button: sender.currentTitle!, input: Double(display.value)!)
        display.value = "\(newValue)"
        output.text = display.value
    }
}

