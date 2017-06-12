//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Mandy Jor on 6/7/17.
//  Copyright © 2017 Mandy Jor. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
    private var accumulator: Double?
    var result: Double? {
        get{
            return accumulator
        }
    }
    
    private var currentSequence: String?
    var sequenceDisplay: String? {
        get{
            return currentSequence
        }
    }
    
    private var resultIsPending = false
    var getResultIsPending: Bool? {
        get{
            return resultIsPending
        }
    }
    
    private var nested = false
    
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
        case clear
    }
    
    private var operations: Dictionary<String, Operation> = [
        "π": Operation.constant(Double.pi),
        "e": Operation.constant(M_E),
        "√": Operation.unary(sqrt),
        "pow": Operation.binary({pow($0, $1)}),
        "cos": Operation.unary(cos),
        "sin": Operation.unary(sin),
        "tan": Operation.unary(tan),
        "±": Operation.unary({ -$0 }),
        "x": Operation.binary({$0 * $1}),
        "÷": Operation.binary({$0 / $1}),
        "+": Operation.binary({$0 + $1}),
        "-": Operation.binary({$0 - $1}),
        "=": Operation.equals,
        "clear": Operation.clear,
    ]
    
    private var pendingBinaryOperation: PendingBinaryOperation?
    
    mutating func performOperation(_ symbol: String) {
        if let operation = operations[symbol]{
            switch operation{
            case .constant(let value):
                accumulator = value
                
                if currentSequence != nil {
                    if resultIsPending {
                        currentSequence = currentSequence! + " " + symbol
                        nested=true
                    }else{
                        currentSequence = symbol
                    }
                }else{
                    currentSequence = symbol
                }
            case .unary(let function):
                if accumulator != nil {
                    if currentSequence != nil {
                        if resultIsPending {
                            currentSequence = currentSequence! + " " + symbol + "(" + String(accumulator!) + ")"
                            nested=true
                        }else{
                            currentSequence = symbol + "(" + currentSequence! + ")"

                        }
                    }else{
                        currentSequence = symbol + "(" + String(accumulator!) + ")"
                    }
                    
                    accumulator = function(accumulator!)
                    print(currentSequence!)
                }
            case .binary(let function):
                if accumulator != nil {
                    pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                    if currentSequence != nil {
                        currentSequence = currentSequence! + " " + symbol

                    }else{
                        currentSequence = String(accumulator!) + " " + symbol
                    }
                    
                    accumulator = nil
                    resultIsPending = true
                    print("Result is Pending: \(resultIsPending)")
                }
            case .equals:
                performPendingBinaryOperation()
            case .clear:
                accumulator = nil
                currentSequence = nil
            }
            
        }
    }
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating private func performPendingBinaryOperation() {
        if accumulator != nil && pendingBinaryOperation != nil && currentSequence != nil {
            if !nested{
                currentSequence = currentSequence! + " " + String(accumulator!)
            }
            nested = false

            accumulator = pendingBinaryOperation!.perform(with:accumulator!)
            print(currentSequence!)

            
            pendingBinaryOperation = nil
            resultIsPending = false
            print("Result is Pending: \(resultIsPending)")
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        accumulator = operand
    }
}
