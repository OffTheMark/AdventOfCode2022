//
//  Day21.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-21.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day21: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day21",
                abstract: "Solve day 21 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let jobsByMonkey: [String: MonkeyJob] = try readLines().reduce(into: [:], { result, line in
                let components = line.components(separatedBy: ": ")
                guard components.count == 2, let job = MonkeyJob(rawValue: components[1]) else {
                    return
                }
                
                result[components[0]] = job
            })
            
            printTitle("Part 1", level: .title1)
            let numberYelledByRootMonkey = part1(jobsByMonkey: jobsByMonkey)
            print(
                "What number will the monkey named root yell?",
                numberYelledByRootMonkey,
                terminator: "\n\n"
            )
        }
        
        fileprivate func part1(jobsByMonkey: [String: MonkeyJob]) -> Int {
            var confirmedValuesByMonkey = [String: Int]()
            var jobsByMonkey = jobsByMonkey
            
            outerLoop: while true {
                for (monkey, job) in jobsByMonkey {
                    let isValueConfirmed: Bool
                    switch job {
                    case .value(let value):
                        confirmedValuesByMonkey[monkey] = value
                        isValueConfirmed = true
                        
                    case .mathOperation(let operation, let lhsMonkey, let rhsMonkey):
                        if let lhs = confirmedValuesByMonkey[lhsMonkey], let rhs = confirmedValuesByMonkey[rhsMonkey] {
                            let value = operation.calculate(lhs: lhs, rhs: rhs)
                            confirmedValuesByMonkey[monkey] = value
                            isValueConfirmed = true
                        }
                        else {
                            isValueConfirmed = false
                        }
                    }
                    
                    if isValueConfirmed {
                        jobsByMonkey.removeValue(forKey: monkey)
                        
                        if monkey == "root" {
                            break outerLoop
                        }
                    }
                }
            }
            
            return confirmedValuesByMonkey["root"]!
        }
    }
}

fileprivate enum MonkeyJob {
    case value(Int)
    case mathOperation(
        operation: MathOperation,
        lhsMonkey: String,
        rhsMonkey: String
    )
    
    init?(rawValue: String) {
        let components = rawValue.components(separatedBy: " ")
        
        if components.count == 1, let value = Int(components[0]) {
            self = .value(value)
            return
        }
        
        guard components.count == 3, let operation = MathOperation(rawValue: components[1]) else {
            return nil
        }
        
        self = .mathOperation(operation: operation, lhsMonkey: components[0], rhsMonkey: components[2])
    }
    
    enum MathOperation: String {
        case add = "+"
        case subtract = "-"
        case multiply = "*"
        case divide = "/"
        
        func calculate(lhs: Int, rhs: Int) -> Int {
            switch self {
            case .add:
                return lhs + rhs
                
            case .subtract:
                return lhs - rhs
            
            case .multiply:
                return lhs * rhs
                
            case .divide:
                return lhs / rhs
            }
        }
    }
}
