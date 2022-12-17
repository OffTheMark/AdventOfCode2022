//
//  Day17.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-16.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day17: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day17",
                abstract: "Solve day 17 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            
        }
    }
}
