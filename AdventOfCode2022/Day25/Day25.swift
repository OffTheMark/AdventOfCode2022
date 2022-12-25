//
//  Day25.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-25.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day25: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day25",
                abstract: "Solve day 25 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let snafuNumbers = try readLines()
            
            printTitle("Part 1", level: .title1)
            let bobConsoleInput = part1(snafuNumbers: snafuNumbers)
            print(
                "What SNAFU number do you supply to Bob's console?",
                bobConsoleInput,
                terminator: "\n\n"
            )
        }
        
        func part1(snafuNumbers: [String]) -> String {
            let sum = snafuNumbers.reduce(into: 0, { sum, snafuNumber in
                guard let value = Int(snafuNumber: snafuNumber) else {
                    return
                }
                
                sum += value
            })
            
            return sum.snafuNumber
        }
    }
}

fileprivate extension Int {
    init?(snafuNumber: String) {
        self = snafuNumber.reversed().enumerated().reduce(into: 0, { result, pair in
            let (position, character) = pair
            let multiplier: Int
            switch character {
            case "0":
                multiplier = 0
                
            case "1":
                multiplier = 1
            
            case "2":
                multiplier = 2
                
            case "-":
                multiplier = -1
                
            case "=":
                multiplier = -2
                
            default:
                return
            }
            
            result += multiplier * Int(pow(5, Double(position)))
        })
    }
    
    // Based on https://www.reddit.com/r/adventofcode/comments/zur1an/comment/j1l070u/
    var snafuNumber: String {
        var number = self
        let characters = ["=", "-", "0", "1", "2"]
        var output = ""
        
        while number > 0 {
            let (quotient, remainder) = (number + 2).quotientAndRemainder(dividingBy: 5)
            number = quotient
            output += characters[remainder]
        }
        
        return String(output.reversed())
    }
}
