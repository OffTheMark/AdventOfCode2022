//
//  Day7.swift
//  AdventOfCode2022
//
//  Created by Marc-Antoine Malépart on 2022-12-06.
//

import Foundation
import ArgumentParser
import AdventOfCodeUtilities

extension Commands {
    struct Day7: DayCommand {
        static var configuration: CommandConfiguration {
            CommandConfiguration(
                commandName: "day7",
                abstract: "Solve day 7 puzzle"
            )
        }
        
        @Argument(help: "Puzzle input path")
        var puzzleInputPath: String
        
        func run() throws {
            
        }
    }
}
