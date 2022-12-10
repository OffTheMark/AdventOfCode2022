//
//  Day10.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-10.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day10: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day10",
                abstract: "Solve day 10 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let commands = try readLines().compactMap(Command.init)
            
            let sumOfSignalStrengths = part1(commands: commands)
            printTitle("Part 1", level: .title1)
            print(
                "What is the sum of these signal strengths during the 20th, 60th, 100th, 140th, 180th and 220th cycle?",
                sumOfSignalStrengths,
                terminator: "\n\n"
            )
        }
        
        func part1(commands: [Command]) -> Int {
            let cyclesToObserve: Set = [19, 59, 99, 139, 179, 219]
            var signalStrengths = [Int]()
            
            var currentCycle = 0
            var x = 1
            
            for command in commands {
                let cycleAtStart = currentCycle
                let valueAtStart = x
                
                switch command {
                case .addX(let value):
                    x += value
                    
                case .noOperation:
                    break
                }
                
                currentCycle += command.cyclesToComplete
                
                let range = cycleAtStart ..< currentCycle
                if let cycle = cyclesToObserve.first(where: { range.contains($0) }) {
                    let signalStrength = (cycle + 1) * valueAtStart
                    signalStrengths.append(signalStrength)
                }
            }
            
            return signalStrengths.reduce(0, +)
        }
    }
    
    enum Command {
        case noOperation
        case addX(value: Int)
        
        init?(rawValue: String) {
            if rawValue == "noop" {
                self = .noOperation
                return
            }
            
            let components = rawValue.components(separatedBy: " ")
            if components.count == 2, let value = Int(components[1]) {
                self = .addX(value: value)
                return
            }
            
            return nil
        }
        
        var cyclesToComplete: Int {
            switch self {
            case .noOperation:
                return 1
                
            case .addX:
                return 2
            }
        }
    }
}
