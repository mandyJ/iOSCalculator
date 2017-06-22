//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Mandy Jor on 6/7/17.
//  Copyright © 2017 Mandy Jor. All rights reserved.
//

import Foundation

struct CalculatorBrain {
    
//    var result: Double? {
//        get{
//            let (result, _, _) = evaluate()
//            return result
//        }
//    }
//    
//    var sequenceDisplay: String {
//        get{
//            let (_, _, description) = evaluate()
//            return description
//        }
//    }
//    
//    var getResultIsPending: Bool {
//        get{
//            let (_, resultIsPending, _) = evaluate()
//            return resultIsPending
//        }
//    }
    
    
    private enum Operation {
        case constant(Double)
        case unary((Double) -> Double)
        case binary((Double, Double) -> Double)
        case equals
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
        "=": Operation.equals
    ]
    
    func evaluate(using variables: Dictionary<String,Double>? = nil)-> (result: Double?, isPending: Bool, description: String) {
        
        print("\n^^^^^^^^^^^^^^^")
        printEntryTypesSequence(sequence: sequence)
        
        var accumulator: Double?
        var resultIsPending = false
        var description: String = ""
        
        var pendingBinaryOperation: PendingBinaryOperation?
        var nested = false
        
        func performPendingBinaryOperation() {
            if accumulator != nil && pendingBinaryOperation != nil && !description.isEmpty{
                if !nested{
                    description = description + " " + String(accumulator!)
                }
                nested = false
                
                accumulator = pendingBinaryOperation!.perform(with:accumulator!)
                print(description)
                
                
                pendingBinaryOperation = nil
                resultIsPending = false
                print("Result is Pending: \(resultIsPending)")
            }
        }
        
        for entryType in sequence {
            switch entryType {
            
            case .operand(let value):
                accumulator = value
            
            case .operation(let symbol):
                if let operation = operations[symbol]{
                    
                    switch operation{
                    case .constant(let value):
                        accumulator = value
                        
                        if !description.isEmpty && resultIsPending {
                            description = description + " " + symbol
                            nested=true
                        }else{
                            description = symbol
                        }
                    case .unary(let function):
                        if accumulator != nil {
                            if !description.isEmpty {
                                if resultIsPending {
                                    description = description + " " + symbol + "(" + String(accumulator!) + ")"
                                    nested=true
                                }else{
                                    description = symbol + "(" + description + ")"
                                    
                                }
                            }else{
                                description = symbol + "(" + String(accumulator!) + ")"
                            }
                            
                            accumulator = function(accumulator!)
                            print(description)
                        }
                    case .binary(let function):
                        if accumulator != nil {
                            pendingBinaryOperation = PendingBinaryOperation(function: function, firstOperand: accumulator!)
                            if !description.isEmpty{
                                description = description + " " + symbol
                                
                            }else{
                                description = String(accumulator!) + " " + symbol
                            }
                            
                            accumulator = nil
                            resultIsPending = true
                        }
                    case .equals:
                        performPendingBinaryOperation()
                    }
                }
            case .variable(let variable):
                if let variableDictionary = variables{
                    accumulator = variableDictionary[variable]
                }else{
                    accumulator = 0
                }
                
                if !description.isEmpty && resultIsPending {
                    description = description + " " + variable
                    nested=true
                }else{
                    description = variable
                }
            }
        }
        print("Result is Pending: \(resultIsPending)")
        return (accumulator, resultIsPending, description)
    }
    
    private struct PendingBinaryOperation{
        let function: (Double, Double) -> Double
        let firstOperand: Double
        
        func perform(with secondOperand: Double) -> Double {
            return function(firstOperand, secondOperand)
        }
    }
    
    mutating func setOperand(_ operand: Double) {
        sequence.append(entryTypes.operand(operand))
    }
    
    private enum entryTypes {
        case operand(Double)
        case variable(String)
        case operation(String)
    }
    
    private var sequence: Array<entryTypes> = []
    
    mutating func performOperation(_ symbol: String) {
        if symbol == "clear" {
            sequence = []
        } else if symbol == "undo" {
            if !sequence.isEmpty {
                sequence.removeLast()
            }
        } else{
            sequence.append(entryTypes.operation(symbol))
        }
    }
    
    mutating func setOperand(variable named: String){
        sequence.append(entryTypes.variable(named))
    }
    
    private func printEntryTypesSequence(sequence: Array<entryTypes>) {
        print("------------------")
        
        for entryType in sequence{
            switch entryType{
            case .operand(let value):
                print(String(value))
            case .variable(let value), .operation(let value):
                print(value)
            }
        }
    }
    
}
