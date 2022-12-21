//
//  Day20.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-20.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Collections

extension Commands {
    struct Day20: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day20",
                abstract: "Solve day 20 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let encryptedFile = try readLines().compactMap(Int.init)
            
            printTitle("Part 1", level: .title1)
            let groveCoordinates = part1(encryptedFile: encryptedFile)
            print(
                "Mix your encrypted file exactly once. What is the sum of the three numbers that form the grove coordinates?",
                groveCoordinates,
                terminator: "\n\n"
            )
        }
        
        func part1(encryptedFile: [Int]) -> Int {
            let count = encryptedFile.count
            var indices = Deque(encryptedFile.indices)
            
            for (index, value) in encryptedFile.enumerated() {
                let indexOfIndex = indices.firstIndex(of: index)!
                indices.remove(at: indexOfIndex)
                
                var insertionIndex = (indexOfIndex + value) % (count - 1)
                if insertionIndex < 0 {
                    insertionIndex += count - 1
                }
                
                indices.insert(index, at: insertionIndex)
            }
            
            let mixedIndexOfZero = indices.firstIndex(of: encryptedFile.firstIndex(of: 0)!)!
            let groveCoordinates = [1_000, 2_000, 3_000].reduce(into: 0, { sum, offset in
                let indicesIndex = (mixedIndexOfZero + offset) % count
                let value = encryptedFile[indices[indicesIndex]]
                sum += value
            })
            return groveCoordinates
        }
    }
}
