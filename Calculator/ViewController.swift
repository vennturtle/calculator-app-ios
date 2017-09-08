//
//  ViewController.swift
//  Calculator
//
//  Created by Student on 9/5/17.
//  Copyright © 2017 Student. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var output: UILabel!
    @IBOutlet weak var history: UILabel!
    
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
        display.append(digit: sender.currentTitle!)
        output.text = display.value
    }
    
    @IBAction func negate(_ sender: UIButton) {
        display.negate()
        output.text = display.value
    }
    
    @IBAction func decimate(_ sender: UIButton) {
        display.decimal()
        output.text = display.value
    }
    
    @IBAction func clear(_ sender: UIButton) {
        if display.value == "0" {
            brain.reset()
        }
        else {
            display.clear()
        }
    }
    @IBAction func operate(_ sender: UIButton) {
        let newValue = brain.exec(button: sender.currentTitle!, input: Double(display.value)!)
        display.value = "\(newValue)"
        output.text = display.value
    }
}

