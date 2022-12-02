//
//  Day1.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day1: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day1",
                abstract: "Solve day 1 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let input: [[Int]] = try readFile().components(separatedBy: "\n\n").map({ block in
                block.components(separatedBy: "\n").compactMap(Int.init)
            })
            
            let numberOfCaloriesOfTopElf = part1(input: input)
            printTitle("Part 1", level: .title1)
            print("Number of calories of top elf:", numberOfCaloriesOfTopElf, terminator: "\n\n")
            
            let numberOfCaloriesOfTop3Elves = part2(input: input)
            printTitle("Part 2", level: .title1)
            print("Number of calories of top 3 elves:", numberOfCaloriesOfTop3Elves)
        }
        
        func part1(input: [[Int]]) -> Int {
            let calorieSums = input.map({ $0.reduce(0, +) })
            return calorieSums.max()!
        }
        
        func part2(input: [[Int]]) -> Int {
            let calorieSums = input.map({ $0.reduce(0, +) })
            let top3Sums = calorieSums.sorted(by: >)[0..<3]
            return top3Sums.reduce(0, +)
        }
    }
}
