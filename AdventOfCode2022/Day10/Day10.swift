//
//  Day10.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-10.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

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
            
            let displayImage = part2(commands: commands)
            printTitle("Part 2", level: .title2)
            print(
                "What eight capital letters appear on your CRT?",
                displayImage,
                separator: "\n"
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
                
                let cycles = cycleAtStart ..< currentCycle
                if let cycle = cyclesToObserve.first(where: { cycles.contains($0) }) {
                    let signalStrength = (cycle + 1) * valueAtStart
                    signalStrengths.append(signalStrength)
                }
            }
            
            return signalStrengths.reduce(0, +)
        }
        
        func part2(commands: [Command]) -> String {
            var pixels = Array(repeating: ".", count: 40 * 6)
            var sprite = Sprite(x: 1)
            var currentCycle = 0
            
            for command in commands {
                let cycleAtStart = currentCycle
                let spriteAtStart = sprite
                
                switch command {
                case .addX(let value):
                    sprite.x += value
                    
                case .noOperation:
                    break
                }
                
                currentCycle += command.cyclesToComplete
                
                let cycles = cycleAtStart ..< currentCycle
                let pixelsToDraw = cycles.filter({ cycle in
                    let horizontalPosition = cycle % 40
                    return spriteAtStart.pixels.contains(horizontalPosition)
                })
                pixelsToDraw.forEach({ pixels[$0] = "#" })
            }
            
            return pixels.chunks(ofCount: 40).map({ $0.joined() }).joined(separator: "\n")
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
        
        struct Sprite {
            var x: Int
            
            var pixels: ClosedRange<Int> { (x - 1) ... (x + 1)}
        }
    }
}
