//
//  Day6.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-06.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities
import Algorithms

extension Commands {
    struct Day6: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day6",
                abstract: "Solve day 6 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            let input = try readFile()
            
            let numberOfCharactersToStartOfPacketMarker = part1(input: input)
            printTitle("Part 1", level: .title1)
            print(
                "How many characters need to be processed before the first start-of-packet marker is detected?",
                numberOfCharactersToStartOfPacketMarker,
                terminator: "\n\n"
            )
            
            let numberOfCharactersToStartOfMessageMarker = part2(input: input)
            printTitle("Part 2", level: .title1)
            print(
                "How many characters need to be processed before the first start-of-message marker is detected?",
                numberOfCharactersToStartOfMessageMarker,
                terminator: "\n\n"
            )
        }
        
        func part1(input: String) -> Int {
            let startOfPacketMarker = input.windows(ofCount: 4)
                .first(where: { substring in
                    Set(substring).count == 4
                })!
            
            return startOfPacketMarker.distance(from: input.startIndex, to: startOfPacketMarker.endIndex)
        }
        
        func part2(input: String) -> Int {
            let startOfMessageMarker = input.windows(ofCount: 14)
                .first(where: { substring in
                    Set(substring).count == 14
                })!
            
            return startOfMessageMarker.distance(from: input.startIndex, to: startOfMessageMarker.endIndex)
        }
    }
}
