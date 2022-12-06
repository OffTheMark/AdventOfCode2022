//
//  Day6.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-06.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

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
        }
        
        func part1(input: String) -> Int {
            let startOfPacketEndOffset = (4 ..< input.count).first(where: { endOffset in
                let endIndex = input.index(input.startIndex, offsetBy: endOffset)
                let startIndex = input.index(endIndex, offsetBy: -4)
                let range = startIndex ..< endIndex
                let characters = input[range]
                let distinctCharacters = Set(characters)
                return distinctCharacters.count == 4
            })!
            
            return startOfPacketEndOffset
        }
    }
}
