//
//  Day14.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-13.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day14: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day14",
                abstract: "Solve day 14 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            // TODO
        }
    }
}
