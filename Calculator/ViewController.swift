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
    @IBOutlet weak var variableDisplay: UILabel!
    
    var isTyping = false
    var alreadyDecimal = false
    var newExpression = false
    var variableDictionary: Dictionary<String, Double>?
    
    @IBAction func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if isTyping {
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }else {
            display.text = digit
            isTyping = true
            
            let (_, resultIsPending, _) = brain.evaluate(using: variableDictionary)
            if !resultIsPending {
                print("result is not pending")
                
                newExpression = true
                print("new expression is: ", newExpression)
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
        let mathematicalSymbol = sender.currentTitle
        
        if mathematicalSymbol != nil {
            if newExpression {
                if mathematicalSymbol != "→M" {
                    print("new expression and we are NOT setting M")
                    
                    brain.performOperation("clear")
                    print("new expression is: ", newExpression)
                }
                
                newExpression = false
                print("new expression is: ", newExpression)
            }
        }
     
        if mathematicalSymbol != "→M" {
            if isTyping{
                if mathematicalSymbol != "undo"{
                    brain.setOperand(displayValue)
                    isTyping = false
                    alreadyDecimal = false
                }
            }
        }
        
        if mathematicalSymbol != nil {
            if mathematicalSymbol == "M" {
                brain.setOperand(variable: "M")
            } else if mathematicalSymbol == "→M" {
                if variableDictionary != nil {
                    variableDictionary?["M"] = displayValue
                }else{
                    variableDictionary = ["M" : displayValue ]
                }
                variableDisplay.text = "M: " + String(describing: variableDictionary!["M"]!)
                isTyping = false
            }else if mathematicalSymbol == "undo"{
                if isTyping{
                    removeLastDigitFromDisplay()
                }else{
                    brain.performOperation(mathematicalSymbol!)
                }
            } else {
                brain.performOperation(mathematicalSymbol!)
            }
        }
        
        let (result, resultIsPending, description) = brain.evaluate(using: variableDictionary)
        if result != nil {
            displayValue = result!
        }
        
        if resultIsPending {
            sequenceDisplay.text = description + " ..."
        }else{
            sequenceDisplay.text = description + " ="
        }

    }
    
    @IBAction func clear(_ sender: UIButton) {
        displayValue = 0
        sequenceDisplay.text = "--"
        variableDisplay.text = "--"
        variableDictionary =  nil
        brain.performOperation("clear")
    }
    
    private func removeLastDigitFromDisplay() {
        var stringNumber  = display.text!
        
        if !stringNumber.isEmpty{
            display.text = String(stringNumber.characters.dropLast(1))
            if String(stringNumber.characters.suffix(1)) == "." {
                alreadyDecimal = false
            }
        }else{
            isTyping = false
        }
    }
}
