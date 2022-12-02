//
//  Day2.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-01.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day2: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day2",
                abstract: "Solve day 2 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            // TODO
        }
    }
}
