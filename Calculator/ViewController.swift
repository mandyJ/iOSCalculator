//
//  ViewController.swift
//  Calculator
//
//  Created by Mandy Jor on 6/6/17.
//  Copyright © 2017 Mandy Jor. All rights reserved.
//

import UIKit
import Darwin

class ViewController: UIViewController {
    
    @IBOutlet weak var display: UILabel!
    
    var isTyping = false
    var isDecimal = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isTyping {
            if !isDecimal {
                let textCurrentlyInDisplay = display.text!
                display.text = textCurrentlyInDisplay + digit
            }
        }else {
            display.text = digit
            isTyping = true
            
        }
    }
    
    var displayValue: Double {
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    fileprivate var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if isTyping{
            brain.setOperand(displayValue)
            isTyping = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        if let result = brain.result {
            displayValue = result
        }
    }
    
}
