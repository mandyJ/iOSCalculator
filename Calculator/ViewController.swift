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
    @IBOutlet weak var sequenceDisplay: UILabel!
    
    var isTyping = false
    var alreadyDecimal = false
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }else {
            display.text = digit
            isTyping = true
            if let resultIsPending = brain.getResultIsPending{
                if !resultIsPending {
                    brain.performOperation("clear")
                }
            }
        }
    }
    
    @IBAction func touchDecimal(_ sender: UIButton) {
        if !alreadyDecimal {
            touchDigit(sender)
            alreadyDecimal = true
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
    
    private var brain = CalculatorBrain()
    
    @IBAction func performOperation(_ sender: UIButton) {
        if isTyping{
            brain.setOperand(displayValue)
            isTyping = false
            alreadyDecimal = false
        }
        
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        
        if let result = brain.result {
            displayValue = result
        }
        
        if let sequence = brain.sequenceDisplay{
            if let resultIsPending = brain.getResultIsPending{
                if resultIsPending {
                    sequenceDisplay.text = sequence + " ..."
                }else{
                    sequenceDisplay.text = sequence + " ="
                }
            }
        }
    }
    
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        sequenceDisplay.text = "--"
        brain.performOperation("clear")
    }
    
}
